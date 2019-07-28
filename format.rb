#!/usr/bin/ruby
# Author: Yilin Zhang

class ClippingFormatter
  # @notebook: {book_title1 => [clip1, clip2, ...], book_title2 => ..}
  # clip: A Clipping Object
  def initialize
    @notebook = Hash.new { |k, v| k[v] = [] }
  end

  # Parse the content in filename
  def parse(filename)
    info = {}
    section = :title
    File.open(filename).each do |line|
      case section
      when :title
        info[:title] = line[0...-2]
        section = :position
      when :position
        info[:position] = parse_position(line)
        section = :content
      when :content
        if line =~ /^==========\r\n$/
          @notebook[info[:title]] << Clipping.new(info[:position],
                                                  info[:content])
          info = {}
          section = :title
        else
          info[:content] = line[0...-2]
          info[:content] = nil if info[:content] == ''
        end
      end
    end
    remove_nil_content
    remove_repetition
  end

  # Format the clippings to .org format.
  def format
    puts '* Kindle Clippings'
    @notebook.each do |title, info|
      puts '** ' + title
      info.each do |clipping|
        puts '- ' + clipping.content
      end
    end
  end

  private

  def remove_nil_content
    new_notebook = Hash.new { |k, v| k[v] = [] }
    @notebook.each do |title, clippings|
      new_notebook[title] = clippings.reject { |c| c.content.nil? }
    end
    @notebook = new_notebook
  end

  # Find the strings that have substring relation, tag them,
  # and only select the last one.
  def remove_repetition
    new_notebook = Hash.new { |k, v| k[v] = [] }
    # Tag all strings by group number
    @notebook.each do |title, clippings|
      tags = Array.new(clippings.length)
      clp_pairs = clippings.combination(2).to_a
      idx_pairs = (0...clippings.length).to_a.combination(2).to_a
      grp_num = 0 # initialize group number
      clp_pairs.each.with_index do |clp_pair, idx|
        if substring_relation?(clp_pair)
          tag0 = tags[idx_pairs[idx][0]]
          tag1 = tags[idx_pairs[idx][1]]
          if tag0.nil? && tag1.nil?
            tag0 = tag1 = grp_num
            grp_num += 1
          elsif tag0.nil?
            tag0 = tag1
          elsif tag1.nil?
            tag1 = tag0
          elsif tag0 <= tag1
            tag1 = tag0
          else
            tag0 = tag1
          end
          tags[idx_pairs[idx][0]] = tag0
          tags[idx_pairs[idx][1]] = tag1
        end
      end

      if grp_num.zero?
        new_notebook[title] = @notebook[title]
        next
      end

      # Remove repetitive contents
      # Record all the indices that is for removing
      rm_tags = Array.new(grp_num) { [] }
      tags.each.with_index do |tag, idx|
        unless tag.nil? then rm_tags[tag] << idx end
      end
      rm_tags = rm_tags.map { |a| a[0...-1] }
      rm_tags = rm_tags.flatten
      # Remove
      clippings = clippings.reject.with_index do |c, idx|
        rm_tags.include?(idx)
      end
      new_notebook[title] = clippings
    end
    @notebook = new_notebook
  end

  # Find the relation of two Clipping objects in string_pair
  def substring_relation?(clipping_pair)
    str0 = clipping_pair[0].content
    str1 = clipping_pair[1].content
    str0.include?(str1) || str1.include?(str0) ? true : false
  end

  def sort_by_position() end

  # Parse position
  def parse_position(line)
    # There are two kinds of position:
    # #123-124 or #123
    position = []
    if /#(?<p1>\d+)-(?<p2>\d+)/ =~ line
      position[0] = p1
      position[1] = p2
    elsif /#(?<p1>\d+)/ =~ line
      position[0] = p1
    end
    position
  end
end

class Clipping
  attr_reader :position, :content
  # position: an Array object [begin, end] or just [page]
  # content:  String
  def initialize(position, content)
    @position = position
    @content = content
  end
end

cf = ClippingFormatter.new
cf.parse(ARGV[0])
cf.format

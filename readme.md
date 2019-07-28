# Kindle Clip Formatter

It formats `My Clippings.txt` into a more organized format (org format).

## Feature

It automatically removes repetitive clippings.

The output looks like this:

```org
* Kindle Clippings
** Book1
- clipping1
- clipping2
- ...
** Book2
- ...
```

## Usage

```
ruby format.rb path/to/My\ Clippings.txt
```
or
```
ruby format.rb path/to/My\ Clippings.txt > my-clippings.org
```
or rename `format.rb` to `format`, make it executable, and put it in any directory in `PATH`
```
format path/to/My\ Clippings.txt > my-clippings.org
```

There you go!

## Todo List

- Adding support for sorting the clippings by position
- Adding support for other output formats.

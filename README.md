# Big Text Generator

Generates big pixelated text using the Unicode Braille Patterns (U+2800–U+28FF).

⣶⠀⠀⠀⠀⠶⣶⠶⠀⣶⠀⣠⡶⠀⣶⠶⠶⠶⠀⠀⠀⠶⣶⠶⠀⣶⠀⠀⣶⠀⠶⣶⠶⠀⣴⠶⠶⣦<br/>
⣿⠀⠀⠀⠀⠀⣿⠀⠀⣿⢾⣏⠀⠀⣿⠶⠶⠀⠀⠀⠀⠀⣿⠀⠀⣿⠶⠶⣿⠀⠀⣿⠀⠀⠻⠶⠶⣦<br/>
⠿⠶⠶⠶⠀⠶⠿⠶⠀⠿⠀⠙⠷⠀⠿⠶⠶⠶⠀⠀⠀⠀⠿⠀⠀⠿⠀⠀⠿⠀⠶⠿⠶⠀⠻⠶⠶⠟<br/>
<br/>
⠀⣠⡶⠋⠉⠳⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠀⠀⢹⣿⠀⠀⠀⠀⠸⠿<br/>
⢰⣿⠁⠀⠀⠀⢹⣷⠀⢹⣿⠊⠻⠀⠀⠀⠀⢹⣿⠉⠀⢸⣿⠊⢹⣷⠀⢹⣿⠀⢰⣏⠑⠇<br/>
⠘⣿⡄⠀⠀⠀⣼⡟⠀⢸⣿⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⢸⣿⠀⢸⣿⠀⢸⣿⠀⠈⠛⢿⣦<br/>
⠀⠈⠛⠦⠤⠞⠋⠀⠀⠼⠿⠄⠀⠀⠀⠀⠀⠘⠿⠤⠂⠼⠿⠄⠸⠿⠄⠼⠿⠄⠸⠢⠤⠟<br/>
<br/>
⠀⣠⣤⣤⣄⠀⢠⣤⣤⣤⣄⠀⠀⠀⢠⣤⣤⣤⠀⣤⣤⠀⢠⣤⡄⢠⣤⣤⣤⠀⢠⣤⡄⠀⣤⡄⠀⠀⣤⣤⣤⣤⣤⢠⣤⡄⢠⣤⡄⢠⣤⡄⠀⣠⣤⣤⡀<br/>
⢸⣿⡏⢹⣿⡇⢸⣿⡏⢹⣿⡇⠀⠀⢸⣿⡏⠉⠀⢻⣿⡄⣼⣿⠃⢸⣿⡏⠉⠀⢸⣿⣿⡀⣿⡇⠀⠀⠉⢹⣿⡏⠉⢸⣿⡇⢸⣿⡇⢸⣿⡇⢸⣿⡏⠿⠿<br/>
⢸⣿⡇⢸⣿⡇⢸⣿⡿⢿⣯⡁⠀⠀⢸⣿⣷⣶⠀⢸⣿⡇⣿⣿⠀⢸⣿⣷⣶⠀⢸⣿⢿⣧⣿⡇⠀⠀⠀⢸⣿⡇⠀⢸⣿⣷⣾⣿⡇⢸⣿⡇⠈⠻⣿⣷⣄<br/>
⢸⣿⡇⢸⣿⡇⢸⣿⡇⢸⣿⡇⠀⠀⢸⣿⡇⠀⠀⠈⣿⣇⣿⡏⠀⢸⣿⡇⠀⠀⢸⣿⠘⣿⣿⡇⠀⠀⠀⢸⣿⡇⠀⢸⣿⡇⢸⣿⡇⢸⣿⡇⢰⣶⡎⣿⣿<br/>
⠈⠻⠿⠿⠟⠁⠸⠿⠇⠸⠿⠇⠀⠀⠸⠿⠿⠿⠇⠀⠿⠿⠿⠇⠀⠸⠿⠿⠿⠇⠸⠿⠀⠹⠿⠇⠀⠀⠀⠸⠿⠇⠀⠸⠿⠇⠸⠿⠇⠸⠿⠇⠈⠻⠿⠿⠋<br/>

[TRY IT HERE](http://www.msarnoff.org/bigtext/)

## Command line

`bigtext` is a Python script that accepts a string via command-line argument or standard input.
The string is rendered into large bitmapped characters and written to standard output.

- `-f font`: specify a custom font. Fonts are defined in PNG files and the [Pillow](https://pypi.python.org/pypi/Pillow) library is required to read them. Several fonts are included in this repository; to use them, place them in a directory called `~/.bigtext`. If no font is specified, the built-in font is used.
- `-g`: print out all glyphs in the specified font. Only ASCII input is supported at this time.
- `-c`: Mac OS X only: write the output to the clipboard instead of standard output.

## Web

`bigtext.html`/`bigtext.js` is a Web-based implementation. The Canvas API is used to read the same font files used by the Python script. The script and any font files used must be served from the same domain (or support [CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing)) to prevent the ["tainted canvas" error](https://www.google.com/search?client=safari&rls=en&q=getImageData+tainted+canvas&ie=UTF-8&oe=UTF-8).

## Font format

For ease of design, the current implementation reads fonts from PNG files. Each PNG is assumed to be
a grid of 16 characters across and 6 characters down, representing the basic ASCII code points (U+0020–U+007F).

One pixel corresponds to one dot in a Braille character. A black pixel indicates a dot should be drawn, and a white pixel indicates a dot should not be drawn. (The grayscale values don't have to be exact; some tolerance is allowed.)

Each cell in the grid must be the same size. The width of a cell must be a multiple of 2, and the height of a cell must be a multiple of 4. (In other words, each character must consist of whole Braille characters.)

However, proportionally-spaced fonts are supported. To indicate that a character is narrower than its cell, place a gray pixel (in any row) in the column just past the desired character boundary. As before, the character width must be a multiple of 2.

## BUT WAIT THERE'S MORE

[BitmapFontGenerator](BitmapFontGenerator/) is a Mac OS X application that can create a PNG bitmap from any font on your system.

## Credits

Made by Matt Sarnoff ([@autorelease](http://twitter.com/autorelease)).

Inspiration from [drawille](https://github.com/asciimoo/drawille) by Adam Tauber and [figlet](http://www.figlet.org) which is older than the internet.

The fonts `atari-st`, `c64`, `chicago`, and `vga` come from Damien Guard's articles ["Typography in 8 Bits"](http://damieng.com/blog/2011/02/20/typography-in-8-bits-system-fonts) and ["Typography in 16 Bits"](http://damieng.com/blog/2011/03/27/typography-in-16-bits-system-fonts). They have been modified slightly to look nicer when converted to Braille.

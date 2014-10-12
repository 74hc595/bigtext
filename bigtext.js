var BigText = (function() {

  var FONT_CHARS_PER_ROW = 16;
  var FONT_NUM_ROWS = 6;
  var BRAILLE_DOTS_WIDE = 2;
  var BRAILLE_DOTS_HIGH = 4;
  var BIT_OFFSETS = [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[0,3],[1,3]];
  var PIXEL_ON_THRESHOLD = 32;
  var WIDTH_MARKER_THRESHOLD = 224;


  function Font(imageURL, didFinishCallback) {
    this.glyphs = [];
    this.glyphOffset = 0x20;
    this.rowsPerGlyph = 0;
    this.loadFromURL(imageURL, didFinishCallback);
  }


  Font.prototype.loadFromURL = function(imageURL, didFinishCallback) {
    var image = new Image();
    image.crossOrigin = "anonymous";
    var font = this;
    image.onload = function() {
      font.loadFromImage(this, didFinishCallback);
    }
    image.src = imageURL;
  }


  Font.prototype.loadFromImage = function(image, didFinishCallback) {
    // check dimensions
    var requiredWidthMultiple = FONT_CHARS_PER_ROW*BRAILLE_DOTS_WIDE;
    if (image.width % requiredWidthMultiple != 0) {
      throw "image width ("+image.width+") is not a multiple of "+requiredWidthMultiple;
    }
    var requiredHeightMultiple = FONT_NUM_ROWS*BRAILLE_DOTS_HIGH;
    if (image.height % requiredHeightMultiple != 0) {
      throw "image height ("+image.height+") is not a multiple of "+requiredHeightMultiple;
    }
    this.rowsPerGlyph = image.height/requiredHeightMultiple;

    // render into a canvas so we can read pixel values
    var canvas = document.createElement("canvas");
    canvas.width = image.width;
    canvas.height = image.height;
    canvas.getContext('2d').drawImage(image, 0, 0, image.width, image.height);
    // extract glyphs
    var glyphBitmapWidth = image.width/FONT_CHARS_PER_ROW;
    var glyphBitmapHeight = image.height/FONT_NUM_ROWS;
    for (var by = 0; by < image.height; by += glyphBitmapHeight) {
      for (var bx = 0; bx < image.width; bx += glyphBitmapWidth) {
        this.glyphs.push(Font.glyphFromSubimage(canvas.getContext('2d'),
              bx, by, glyphBitmapWidth, glyphBitmapHeight));
      }
    }
    if (didFinishCallback) {
      didFinishCallback();
    }
  }


  Font.glyphFromSubimage = function(ctx, offsetX, offsetY, w, h) {
    // create a string for each row
    var glyph = new Array(h/BRAILLE_DOTS_HIGH);
    for (var i = 0; i < glyph.length; i++) { glyph[i] = ""; }
    // then scan the bitmap to determine the glyph width
    // (can be specified with a gray pixel)
    var glyphWidth = w;
    for (var y = offsetY; y < offsetY+h; y++) {
      for (var x = offsetX; x < offsetX+w; x++) {
        var pixel = ctx.getImageData(x, y, 1, 1).data[0];
        if (pixel > PIXEL_ON_THRESHOLD && pixel <= WIDTH_MARKER_THRESHOLD) {
          glyphWidth = Math.min(glyphWidth, x-offsetX);
        }
      }
    }
    // width must be a multiple of the number of columns in a Braille character
    if (glyphWidth % BRAILLE_DOTS_WIDE != 0) {
      throw "width "+glyphWidth+" specified for glyph at ("+offsetX+","+offsetY+"( is not a multiple of "+BRAILLE_DOTS_WIDE;
    }
    var row = 0;
    for (var y = offsetY; y < offsetY+h; y += BRAILLE_DOTS_HIGH, row++) {
      for (var x = offsetX; x < offsetX+glyphWidth; x += BRAILLE_DOTS_WIDE) {
        glyph[row] += Font.brailleFromSubimage(ctx, x, y);
      }
    }
    return glyph;
  }


  Font.brailleFromSubimage = function(ctx, x, y) {
    var codePoint = 0x2800;
    for (var bit = 0; bit < BIT_OFFSETS.length; bit++) {
      var pixel = ctx.getImageData(x+BIT_OFFSETS[bit][0], y+BIT_OFFSETS[bit][1], 1, 1).data[0];
      codePoint |= (pixel < PIXEL_ON_THRESHOLD) ? (1 << bit) : 0;
    }
    return String.fromCharCode(codePoint);
  }


  Font.prototype.glyphForCharCode = function(charCode) {
    charCode -= this.glyphOffset;
    if (charCode >= 0 && charCode < this.glyphs.length) {
      return this.glyphs[charCode];
    } else {
      return null;
    }
  }


  function Generator(font) {
    this.setFont(font);
  }


  Generator.prototype.setFont = function(font) {
    if (font instanceof Font) {
      this.font = font;
    } else if (typeof font === "string") {
      this.font = new Font(font);
    }
  }


  Generator.prototype.renderString = function(input) {
    if (!this.font) {
      return "error: no font specified";
    }

    var rows = new Array(this.font.rowsPerGlyph);
    for (var i = 0; i < rows.length; i++) { rows[i] = ""; }
    var rowidx = 0;
    for (var c = 0; c < input.length; c++) {
      var charCode = input.charCodeAt(c);
      if (charCode != 10) { // not a newline?
        var glyph = this.font.glyphForCharCode(charCode);
        if (glyph !== null) {
          for (var r = 0; r < glyph.length; r++) {
            rows[rowidx+r] += glyph[r];
          }
        }
      } else {
        // append new rows
        for (var i = 0; i < this.font.rowsPerGlyph; i++) { rows.push(""); }
        rowidx += this.font.rowsPerGlyph;
      }
    }

    // Trim excess blanks off the end of each row
    var regex = /(\u2800+)$/g;
    for (var i = 0; i < rows.length; i++) {
      rows[i] = rows[i].replace(regex, "");
    }

    return rows.join("\n");
  }


  return {
    Font: Font,
    Generator: Generator
  };
}());


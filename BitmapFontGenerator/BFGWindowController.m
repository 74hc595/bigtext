//
//  BFGWindowController.m
//  BitmapFontGenerator
//
//  Created by Matt Sarnoff on 10/10/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

#import "BFGWindowController.h"
@import Accelerate;

static const NSGlyph kStartGlyphIndex = 0x20;
static const NSGlyph kEndGlyphIndex = 0x7F;
static const NSUInteger kNumGlyphs = (kEndGlyphIndex+1-kStartGlyphIndex);
static const NSUInteger kNumGlyphsPerRow = 16;
static const NSUInteger kNumGlyphRows = kNumGlyphs/kNumGlyphsPerRow;
static const NSUInteger kRequiredGlyphWidthMultiple = 2;
static const NSUInteger kRequiredGlyphHeightMultiple = 4;

// rounds x to an integer before rounding it up to the nearest multiple
static inline CGFloat roundUpToMultiple(CGFloat x, CGFloat multiple) {
    return multiple * ceil(round(x) / multiple);
}


@interface BFGWindowController ()
@property (weak) IBOutlet NSPopUpButton *fontSelector;
@property (weak) IBOutlet NSTextField *fontSizeTextField;
@property (weak) IBOutlet NSImageView *bitmapPreview;
@property (weak) IBOutlet NSTextField *summary;
@property (nonatomic,strong) NSString *fontName;
@property (nonatomic,assign) CGFloat fontSize;
@property (nonatomic,strong) NSImage *bitmapFont;
@property (nonatomic,strong) NSURL *outputFileURL;
@end


@implementation BFGWindowController

static NSGlyph sGlyphsToRender[kNumGlyphs];

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        for (NSGlyph g = kStartGlyphIndex; g <= kEndGlyphIndex; g++) {
            sGlyphsToRender[g] = g;
        }
    });
}


- (instancetype)init
{
    return [self initWithWindowNibName:@"BFGWindowController"];
}


- (instancetype)initWithWindowNibName:(NSString *)windowNibName
{
    if ((self = [super initWithWindowNibName:windowNibName])) {
        _fontName = @"Helvetica";
        _fontSize = 12;
    }
    return self;
}


- (void)awakeFromNib
{
    NSArray *allFonts = [[NSFontManager sharedFontManager] availableFonts];
    [_fontSelector addItemsWithTitles:allFonts];
    [_fontSelector selectItemWithTitle:_fontName];
    [self regenerateBitmapFont];
}


- (void)setFontName:(NSString *)fontName
{
    _fontName = fontName;
    [self regenerateBitmapFont];
}


- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    [self regenerateBitmapFont];
}


- (void)setOutputFileURL:(NSURL *)outputFileURL
{
    _outputFileURL = outputFileURL;
    self.window.representedURL = _outputFileURL;
    self.window.title = [_outputFileURL lastPathComponent];
}


- (void)regenerateBitmapFont
{
    NSFont *font = [NSFont fontWithName:_fontName size:_fontSize];
    NSDictionary *attrs = @{NSFontAttributeName: font,
                            NSForegroundColorAttributeName: NSColor.blackColor};
    NSSize imageSize = NSZeroSize;
    NSSize maxGlyphSize = NSZeroSize;
    
    // get font metrics
    NSSize glyphAdvancements[kNumGlyphs];
    CGFloat maxAdvancement;
    [font getAdvancements:glyphAdvancements forGlyphs:sGlyphsToRender count:kNumGlyphs];
    vDSP_maxvD((double *)glyphAdvancements, 2, &maxAdvancement, kNumGlyphs);
    
    maxGlyphSize.width = roundUpToMultiple(maxAdvancement, kRequiredGlyphWidthMultiple);
    imageSize.width = maxGlyphSize.width * kNumGlyphsPerRow;
    maxGlyphSize.height = roundUpToMultiple(font.ascender-font.descender, kRequiredGlyphHeightMultiple);
    imageSize.height = maxGlyphSize.height * kNumGlyphRows;
    
    // create an image
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                         pixelsWide:imageSize.width
                                                                         pixelsHigh:imageSize.height
                                                                      bitsPerSample:8
                                                                    samplesPerPixel:3
                                                                           hasAlpha:NO
                                                                           isPlanar:NO
                                                                     colorSpaceName:NSDeviceRGBColorSpace
                                                                        bytesPerRow:0
                                                                       bitsPerPixel:32];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
    [context setShouldAntialias:NO];
    [NSGraphicsContext setCurrentContext:context];
    [NSColor.whiteColor set];
    NSRectFill(NSMakeRect(0, 0, imageSize.width, imageSize.height));
    
    NSPoint pt = NSMakePoint(0, imageSize.height-maxGlyphSize.height);
    BOOL oddRow = YES;
    for (NSGlyph g = 0; g < kNumGlyphs; g++) {
        // shade the background with a checkerboard pattern
        // (has no effect on the character patterns)
        if (g % 2 == oddRow) {
            [[NSColor colorWithDeviceWhite:0.98 alpha:1] set];
            NSRectFill(NSMakeRect(pt.x, pt.y, maxGlyphSize.width, maxGlyphSize.height));
        }
        
        // draw the character
        // who needs core text? :)
        NSString *ch = [NSString stringWithFormat:@"%c", g+kStartGlyphIndex];
        NSSize actualGlyphSize = [ch sizeWithAttributes:attrs];
        [ch drawAtPoint:pt withAttributes:attrs];
        NSUInteger advancement = roundUpToMultiple(actualGlyphSize.width, kRequiredGlyphWidthMultiple);
        if (advancement < maxGlyphSize.width && advancement > 0) {
            [NSColor.grayColor set];
            NSRectFill(NSMakeRect(pt.x+advancement, pt.y+maxGlyphSize.height-1, 1, 1));
        }
        
        // advance to the next glyph
        pt.x += maxGlyphSize.width;
        if (g % kNumGlyphsPerRow == kNumGlyphsPerRow-1) {
            pt.x = 0;
            pt.y -= maxGlyphSize.height;
            oddRow = !oddRow;
        }
    }
    
    NSImage *bitmapFont = [[NSImage alloc] initWithSize:imageSize];
    [bitmapFont addRepresentation:imageRep];
    self.bitmapFont = bitmapFont;
    [_bitmapPreview setImage:bitmapFont];
    [_summary setStringValue:[NSString stringWithFormat:@"Max. glyph size: %g \u00D7 %g    Image size: %g \u00D7 %g",
                              maxGlyphSize.width, maxGlyphSize.height,
                              imageSize.width, imageSize.height]];
}


- (void)writeBitmapToURL:(NSURL *)url
{
    NSData *imageData = [_bitmapFont.representations.firstObject representationUsingType:NSPNGFileType properties:nil];
    [imageData writeToURL:_outputFileURL atomically:NO];
}


- (void)chooseOutputFileWithMessage:(NSString *)message prompt:(NSString *)prompt successHandler:(void (^)(void))handler
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.message = message;
    savePanel.prompt = prompt;
    savePanel.allowedFileTypes = @[(__bridge NSString *)kUTTypePNG];
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            self.outputFileURL = [savePanel URL];
            if (handler) {
                handler();
            }
        }
    }];
}


- (IBAction)saveDocument:(id)sender
{
    if (!_outputFileURL) {
        [self saveDocumentAs:self];
    } else {
        [self writeBitmapToURL:_outputFileURL];
    }
}


- (IBAction)saveDocumentAs:(id)sender
{
    [self chooseOutputFileWithMessage:@"" prompt:nil successHandler:^{
        [self writeBitmapToURL:_outputFileURL];
    }];
}


- (IBAction)increaseFontSize:(id)sender
{
    if (_fontSize < 255) {
        self.fontSize++;
    }
}


- (IBAction)decreaseFontSize:(id)sender
{
    if (_fontSize > 1) {
        self.fontSize--;
    }
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL enabled = YES;
    SEL action = menuItem.action;
    if (action == @selector(saveDocument:)) {
        menuItem.title = (_outputFileURL) ? @"Save" : @"Save\u2026";
    } else if (action == @selector(saveDocumentAs:)) {
        enabled = (_outputFileURL > 0);
    } else if (action == @selector(increaseFontSize:)) {
        enabled = (_fontSize < 255);
    } else if (action == @selector(decreaseFontSize:)) {
        enabled = (_fontSize > 1);
    }
    return enabled;
}

@end

//
//  BFGWindowController.h
//  BitmapFontGenerator
//
//  Created by Matt Sarnoff on 10/10/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BFGWindowController : NSWindowController

- (IBAction)saveDocument:(id)sender;
- (IBAction)saveDocumentAs:(id)sender;
- (IBAction)increaseFontSize:(id)sender;
- (IBAction)decreaseFontSize:(id)sender;

@end

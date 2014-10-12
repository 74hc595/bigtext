//
//  AppDelegate.m
//  BitmapFontGenerator
//
//  Created by Matt Sarnoff on 10/10/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

#import "AppDelegate.h"
#import "BFGWindowController.h"

@implementation AppDelegate {
    NSMutableArray *_windowControllers;
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _windowControllers = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
    [self newDocument:self];
}


- (IBAction)newDocument:(id)sender
{
    BFGWindowController *windowController = [[BFGWindowController alloc] init];
    [_windowControllers addObject:windowController];
    [windowController showWindow:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
    [_windowControllers removeObject:[notification.object windowController]];
}

@end

//
//  AppDelegate.m
//  ScreensaverBootstrap
//
//  Created by orta therox on 11/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "AppDelegate.h"
#import "GamesScreensaverView.h"

@implementation AppDelegate {
    GamesScreensaverView *_screensaver;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
     _screensaver = [[GamesScreensaverView alloc] initWithFrame:_mainView.bounds isPreview:NO];
    [_mainView addSubview:_screensaver];
    [_screensaver startAnimation];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [_screensaver stopAnimation];
}

- (IBAction)showPopoverWindow:(id)sender {
    if ([_screensaver hasConfigureSheet]) {
        NSWindow *window = [_screensaver configureSheet];
        [NSApp beginSheet:window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

@end

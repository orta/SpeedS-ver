//
//  AppDelegate.m
//  ScreensaverBootstrap
//
//  Created by orta therox on 11/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "AppDelegate.h"
#import "GamesScreensaverView.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    GamesScreensaverView *screensaver = [[GamesScreensaverView alloc] initWithFrame:_mainView.bounds isPreview:NO];
    [_mainView addSubview:screensaver];
}

@end

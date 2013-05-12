//
//  NSUserDefaults+SCcreenSaverDefaults.m
//  GamesScreensaver
//
//  Created by orta therox on 12/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "NSUserDefaults+ScreenSaverDefaults.h"
#import <ScreenSaver/ScreenSaver.h>

@implementation NSUserDefaults (ScreenSaverDefaults)

+ (NSUserDefaults *)userDefaults {
    // When in the bootstrap, use defaults
    return [self standardUserDefaults];

    // Otherwise use ScreenSaverDefaults
//    return [ScreenSaverDefaults defaultsForModuleWithName:@"TAS-Games-Saver"];
}

@end

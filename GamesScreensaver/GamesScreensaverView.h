//
//  GamesScreensaverView.h
//  GamesScreensaver
//
//  Created by orta therox on 06/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "RMVideoView.h"

@interface GamesScreensaverView : ScreenSaverView <RMVideoViewDelegate>
-(void)setMuted:(BOOL)muted;
@end

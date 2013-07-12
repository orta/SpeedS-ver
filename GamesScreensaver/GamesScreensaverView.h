//
//  GamesScreensaverView.h
//  GamesScreensaver
//
//  Created by orta therox on 06/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "RMVideoView.h"

extern  NSString *ProgressDefault;
extern  NSString *StreamValueProgressDefault;
extern  NSString *FileMD5Default;
extern  NSString *YoutubeURLDefault;
extern  NSString *MovieNameDefault;
extern  NSString *MuteDefault;
extern  NSString *StreamDefault;

@interface GamesScreensaverView : ScreenSaverView <RMVideoViewDelegate>
- (void)setMuted:(BOOL)muted;
- (void)reset;
@end

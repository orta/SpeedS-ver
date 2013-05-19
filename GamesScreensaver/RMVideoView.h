//
//  AVPlayer.h
//  GamesScreensaver
//
//  Created by orta therox on 14/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@protocol RMVideoViewDelegate <NSObject>
- (void)videoViewIsReadyToPlay;
@end

@interface RMVideoView : NSView

@property (weak) id <RMVideoViewDelegate> delegate;
@property (nonatomic, readonly, strong) AVPlayer *player;
@property (nonatomic, readonly, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, retain) NSURL *videoURL;
@property (nonatomic, retain) NSString *videoPath;

- (void) play;

@end

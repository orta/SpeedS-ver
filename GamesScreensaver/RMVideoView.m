//
//  AVPlayer.m
//  GamesScreensaver
//
//  Created by orta therox on 14/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "RMVideoView.h"

static void *RMVideoViewPlayerLayerReadyForDisplay = &RMVideoViewPlayerLayerReadyForDisplay;
static void *RMVideoViewPlayerItemStatusContext = &RMVideoViewPlayerItemStatusContext;

@interface RMVideoView()

- (void)onError:(NSError*)error;
- (void)onReadyToPlay;
- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys;

@end

@implementation RMVideoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        _player = [[AVPlayer alloc] init];
        [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:RMVideoViewPlayerItemStatusContext];
    }

    return self;
}

- (void) dealloc {
    [self.player pause];
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
    [self removeObserver:self forKeyPath:@"playerLayer.readyForDisplay"];
}

- (void) setVideoPath:(NSString *)videoPath {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    [self setVideoURL:url];
}

- (void) setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;

    [self.player pause];
    [self.playerLayer removeFromSuperlayer];

    AVURLAsset *asset = [AVAsset assetWithURL:self.videoURL];
    NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"hasProtectedContent", @"tracks", @"duration", nil];
    [asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
        });
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == RMVideoViewPlayerItemStatusContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                [self onReadyToPlay];
                break;
            case AVPlayerItemStatusFailed:
                [self onError:nil];
                break;
        }
    } else if (context == RMVideoViewPlayerLayerReadyForDisplay) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
            self.playerLayer.hidden = NO;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Private

- (void)onError:(NSError *)error { // Notify delegate
}

- (void)onReadyToPlay { // Notify delegate
    [_delegate videoViewIsReadyToPlay];
}

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
    for (NSString *key in keys) {
        NSError *error = nil;
        if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
            [self onError:error];
            return;
        }
    }

    if (!asset.isPlayable || asset.hasProtectedContent) {
        [self onError:nil];
        return;
    }

    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) { // Asset has video tracks
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.layer.bounds;
        self.playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        self.playerLayer.hidden = YES;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

        [self.layer addSublayer:self.playerLayer];
        [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:RMVideoViewPlayerLayerReadyForDisplay];
    }

    // Create a new AVPlayerItem and make it our player's current item.
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

#pragma mark - Public

- (void) play {
    [self.player play];
}

@end

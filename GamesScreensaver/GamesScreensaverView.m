//
//  GamesScreensaverView.m
//  GamesScreensaver
//
//  Created by orta therox on 06/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "GamesScreensaverView.h"
#import <QuickTime/QuickTime.h>
#import <QTKit/QTKit.h>

@implementation GamesScreensaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        QTMovieView * movieView = [[QTMovieView alloc] initWithFrame:self.bounds];
        NSString *moviePath = @"/Volumes/Cache/orta/Desktop/MovieScreenSaver/MovieScreenSaver/Art.sy_Screencast_Basel.mov";
        NSError *error = nil;
        QTMovie *movie = [QTMovie movieWithFile:moviePath error:&error];
        if (error) {
            NSLog(@"%@ ", error.localizedDescription);
        }
        [movieView setMovie:movie];

        [self addSubview:movieView];
        [movieView play:self];
    }
    return self;
}

- (void)startAnimation {
    [super startAnimation];
}

- (void)stopAnimation {
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
}

- (void)animateOneFrame {
    return;
}

- (BOOL)hasConfigureSheet {
    return NO;
}

- (NSWindow*)configureSheet {
    return nil;
}

@end

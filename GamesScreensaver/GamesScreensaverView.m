//
//  GamesScreensaverView.m
//  GamesScreensaver
//
//  Created by orta therox on 06/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "GamesScreensaverView.h"
#import "HCYoutubeParser.h"
#import <QuickTime/QuickTime.h>
#import <QTKit/QTKit.h>
#import "NSFileManager+DirectoryLocations.h"
#import "AFDownloadRequestOperation.h"
#import "DDProgressView.h"

// Switch form using the bootstrapped defaults to the
// ScreenSaver defaults thing

#if FALSE
    #define standardUserDefaults defaultsForModuleWithName:@"Games"
#endif

static const CGSize ThumbnailSize = { 300.0, 400.0 };
static const CGSize ProgressSize = { 300.0, 24.0 };
static NSString *ProgressDefault = @"ProgressDefault";

@implementation GamesScreensaverView {
    NSString *_currentVideoPath;
    NSInteger _numberOfFailedRequests;

    DDProgressView *_progressView;
    NSImageView *_thumbnailImageView;
    QTMovieView *_movieView;
    QTMovie *_movie;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];

    if (self) {
        if (!isPreview) {

            NSString *filePath = [[NSFileManager defaultManager] applicationSupportDirectory];
            _currentVideoPath = [filePath stringByAppendingPathComponent:@"movie.mp4"];

            if ([[NSFileManager defaultManager] fileExistsAtPath:_currentVideoPath]){
                [self playDownloadedFileAtPath:_currentVideoPath];
            } else {
                [self getRandomVideo];
            }

        } else {
            [self setupPreview];
        }

    }
    return self;
}

- (void)setupPreview {
    // TODO
}

- (void)getRandomVideo {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"metadata" ofType:@"json"];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"Data Error : %@", error.localizedDescription);
        return;
    }

    NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"JSON Error : %@", error.localizedDescription);
        return;
    }

    NSInteger categoryIndex = arc4random() % json.count;
    NSDictionary *category = json[categoryIndex];

    NSString *console = category[@"console"];

    NSArray *movies = category[@"movies"];
    NSInteger movieIndex = arc4random() % movies.count;
    NSDictionary *movie = movies[movieIndex];

    NSString *videoName = movie[@"name"];
    NSURL *videoURL = [NSURL URLWithString: movie[@"url"]];

    [HCYoutubeParser thumbnailForYoutubeURL:videoURL thumbnailSize:YouTubeThumbnailDefaultMaxQuality completeBlock:^(NSImage *image, NSError *error) {
        [self addThumbnailWithImage:image];
    }];

    [HCYoutubeParser h264videosWithYoutubeURL:videoURL completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
        NSArray *orderedByAwesome = @[@"hd1080", @"hd720", @"highres", @"medium", @"small"];
//        NSArray *orderedByAwesome = @[@"small"];
        NSString *key = nil;
        for (NSString *potentialKey in orderedByAwesome.reverseObjectEnumerator) {
            if(videoDictionary[potentialKey]){
                key = potentialKey;
            }
        }
        
        NSString *youtubeURL = videoDictionary[key];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:youtubeURL]];
        
        AFDownloadRequestOperation *download = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:_currentVideoPath shouldResume:NO];
        [download setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self removeProgressIndicator];
            [self removeThumbnailImage];
            [self playDownloadedFileAtPath:_currentVideoPath];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (_numberOfFailedRequests != 5) {
                [self getRandomVideo];
                return;
            }
            _numberOfFailedRequests++;
        }];

        [download setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            _progressView.progress = totalBytesReadForFile / (CGFloat)totalBytesExpectedToReadForFile;
        }];

        [self addProgressIndicatorToView];
        [download start];
    }];
}

- (void)addProgressIndicatorToView {
    CGFloat margin = 16;
    CGRect progressRect = CGRectMake(CGRectGetWidth(self.bounds)/2 - ProgressSize.width/2,
                                  CGRectGetHeight(self.bounds)/2 - ProgressSize.height/2 - ThumbnailSize.height / 2 - margin,
                                  ProgressSize.width, ProgressSize.height);
    _progressView = [[DDProgressView alloc] initWithFrame:progressRect];
    [self addSubview:_progressView];
}

- (void)removeProgressIndicator {
    [_progressView removeFromSuperview];
    _progressView = nil;
}

- (void)addThumbnailWithImage:(NSImage *)image {
    CGRect imageRect = CGRectMake(CGRectGetWidth(self.bounds)/2 - ThumbnailSize.width/2,
                                  CGRectGetHeight(self.bounds)/2 - ThumbnailSize.height/2,
                                  ThumbnailSize.width, ThumbnailSize.height);
    
    _thumbnailImageView = [[NSImageView alloc] initWithFrame:imageRect];
    [_thumbnailImageView setImage:image];
    [self addSubview:_thumbnailImageView];
}

- (void)removeThumbnailImage {
    [_thumbnailImageView removeFromSuperview];
    _thumbnailImageView = nil;
}

- (void)playDownloadedFileAtPath:(NSString *)path {
    _movieView = [[QTMovieView alloc] initWithFrame:self.bounds];
    [_movieView setControllerVisible:NO];
    
    NSError *error = nil;
    _movie = [QTMovie movieWithFile:path error:&error];
    if (error) {
        NSLog(@"%@ ", error.localizedDescription);
    }
    [_movieView setMovie:_movie];

    [self addSubview:_movieView];
    [_movieView play:self];

    NSString *timeString = [[NSUserDefaults standardUserDefaults] stringForKey:ProgressDefault];
    if (timeString) {
        [_movie setCurrentTime: QTTimeFromString(timeString)];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEnded) name:QTMovieDidEndNotification object:_movie];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieProgress) name:QTMovieTimeDidChangeNotification object:_movie];
}

- (void)movieEnded {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_currentVideoPath error:&error];
    if (error) {
        NSLog(@"Error %@", error.localizedDescription);
        return;
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ProgressDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_movieView removeFromSuperview];
    [self getRandomVideo];
}

- (void)startAnimation {
    [super startAnimation];
}

- (void)stopAnimation {
    [super stopAnimation];

    if (_movieView) {
        NSString *time = QTStringFromTime(_movie.currentTime);
        [[NSUserDefaults standardUserDefaults] setValue:time forKey:ProgressDefault];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
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

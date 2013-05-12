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
#import "NSString+MD5.h"
#import "ScreenSaverConfig.h"

// Switch form using the bootstrapped defaults to the
// ScreenSaver defaults thing

#if YES
    #define standardUserDefaults defaultsForModuleWithName:@"Games"
#endif

static const CGSize ThumbnailSize = { 320.0, 260.0 };
static const CGSize ProgressSize = { 300.0, 24.0 };

static NSString *ProgressDefault = @"ProgressDefault";
static NSString *FileMD5Default = @"FileMD5Default";
static NSString *YoutubeURLDefault = @"YoutubeURLDefault";
static NSString *MovieNameDefault = @"MovieNameDefault";

@implementation GamesScreensaverView {
    NSString *_currentVideoPath;
    NSString *_currentVideoURL;
    
    NSInteger _numberOfFailedRequests;
    BOOL _isPreview;

    DDProgressView *_progressView;
    NSImageView *_thumbnailImageView;
    QTMovieView *_movieView;
    QTMovie *_movie;
    ScreenSaverConfig *_config;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];

    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        _isPreview = isPreview;
        _config = [[ScreenSaverConfig alloc] init];
    }
    return self;
}


- (void)startAnimation {
    [super startAnimation];

    NSString *md5Filename = [[NSUserDefaults standardUserDefaults] stringForKey:FileMD5Default];
    if (md5Filename) {
        _currentVideoURL = [[NSUserDefaults standardUserDefaults] stringForKey:YoutubeURLDefault];
        _currentVideoPath = [self appSupportPathWithFilename:md5Filename];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:_currentVideoPath]){
        [self playDownloadedFileAtPath:_currentVideoPath];
    } else {
        [self getNextVideo];
    }
}

- (void)stopAnimation {
    [super stopAnimation];

    if (_movieView) {
        NSString *time = QTStringFromTime(_movie.currentTime);
        [[NSUserDefaults standardUserDefaults] setValue:time forKey:ProgressDefault];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [_movie stop];
    }
}

- (void)setupPreview {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:self.bounds];
    [textField setStringValue:@"NO PREVIEW"];
    [self addSubview:textField];
}

- (void)getNextVideo {
    if (!_currentVideoPath || !_currentVideoURL) {

        // If we have both of the above then skip finding
        // a new one from the JSON.

        NSArray *json = [_config appMetadata];
        NSInteger categoryIndex = arc4random() % json.count;
        NSDictionary *category = json[categoryIndex];

        //    NSString *console = category[@"console"];
        NSArray *movies = category[@"movies"];
        NSInteger movieIndex = arc4random() % movies.count;
        NSDictionary *movie = movies[movieIndex];

        NSString *videoName = movie[@"name"];
        _currentVideoURL = movie[@"url"];
        _currentVideoPath = [self appSupportPathWithFilename:[videoName MD5Hash]];

        [[NSUserDefaults standardUserDefaults] setObject:videoName forKey:MovieNameDefault];
        [[NSUserDefaults standardUserDefaults] setObject:[videoName MD5Hash] forKey:FileMD5Default];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }

    NSURL *youtubeURL = [NSURL URLWithString:_currentVideoURL];
    [HCYoutubeParser thumbnailForYoutubeURL:youtubeURL thumbnailSize:YouTubeThumbnailDefaultMaxQuality completeBlock:^(NSImage *image, NSError *error) {
        [self addThumbnailWithImage:image];
    }];

    [HCYoutubeParser h264videosWithYoutubeURL:youtubeURL completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
        NSString *key = nil;
        for (NSString *potentialKey in _config.availableYoutubeSizes.reverseObjectEnumerator) {
            if(videoDictionary[potentialKey]){
                key = potentialKey;
            }
        }
        
        NSString *youtubeMP4URL = videoDictionary[key];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:youtubeMP4URL]];
        
        AFDownloadRequestOperation *download = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:_currentVideoPath shouldResume:YES];
        [download setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self removeProgressIndicator];
            [self removeThumbnailImage];
            [self playDownloadedFileAtPath:_currentVideoPath];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (_numberOfFailedRequests != 5) {
                [self getNextVideo];
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
                          CGRectGetHeight(self.bounds)/2 - ProgressSize.height - ThumbnailSize.height / 2 - margin,
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
//    [_movieView setControllerVisible:NO];
    _movieView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _movieView.autoresizesSubviews = YES;
    _movieView.preservesAspectRatio = YES;
    
    NSError *error = nil;
    _movie = [QTMovie movieWithFile:path error:&error];
    if (error) {
        NSLog(@"%@ ", error.localizedDescription);
    }
    [_movieView setMovie:_movie];

    [self addSubview:_movieView];

    if (!_isPreview) {
        [_movieView play:self];
    }

    NSString *timeString = [[NSUserDefaults standardUserDefaults] stringForKey:ProgressDefault];
    if (timeString) {
        [_movie setCurrentTime: QTTimeFromString(timeString)];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEnded) name:QTMovieDidEndNotification object:_movie];
}

- (void)movieEnded {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_currentVideoPath error:&error];
    if (error) {
        NSLog(@"Error %@", error.localizedDescription);
        return;
    }

    _currentVideoURL = nil;
    _currentVideoPath = nil;

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MovieNameDefault];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FileMD5Default];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ProgressDefault];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_movieView removeFromSuperview];
    [self getNextVideo];
}

- (NSString *)appSupportPathWithFilename:(NSString *)filename {
    NSString *filePath = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSString *fileWithExtention = [NSString stringWithFormat:@"%@.mp4", filename];
    return [filePath stringByAppendingPathComponent:fileWithExtention];
}

- (void)animateOneFrame {
    return;
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow *)configureSheet {
    return [_config configureWindow];
}

@end

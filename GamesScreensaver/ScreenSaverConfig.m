//
//  ScreenSaverConfig.m
//  GamesScreensaver
//
//  Created by orta therox on 11/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ScreenSaverConfig.h"
#import "NSUserDefaults+ScreenSaverDefaults.h"
#import <QuartzCore/QuartzCore.h>
#import "GamesScreensaverView.h"

static NSArray *YoutubeSizes;
static NSString *SizeIndexDefault = @"SizeIndexDefault";
static NSString *AvailabilitiesDefault = @"AvailabilitiesDefault";

@implementation ScreenSaverConfig {
    IBOutlet NSWindow *_configureSheet;
    IBOutlet NSButton *_okButton;

    IBOutlet NSPopUpButtonCell *_popupButtonCell;
    IBOutlet NSTableColumn *_titleTableColumn;
    IBOutlet NSButton *_muteCheckBox;
    IBOutlet NSButton *_streamCheckBox;

    IBOutlet NSView *_aboutView;
    IBOutlet NSView *_settingsView;

    NSInteger _sizeIndex;
    NSMutableArray *_consoleAvailabilities;

    NSArray *_allAppMetadata;
    NSArray *_publicAppMetaData;

    BOOL _showingAbout;
    BOOL _installedTweetbot;
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    // Setup 
    YoutubeSizes = @[@"hd1080", @"hd720", @"highres", @"medium", @"small"];

    if ([[NSUserDefaults userDefaults] valueForKey:SizeIndexDefault]) {
        _sizeIndex = [[NSUserDefaults userDefaults] integerForKey:SizeIndexDefault];
    } else {
        _sizeIndex = 1;
    }

    _consoleAvailabilities = [[[NSUserDefaults userDefaults] arrayForKey:AvailabilitiesDefault] mutableCopy];
    if (!_consoleAvailabilities) {
        _consoleAvailabilities = [self initialAvailabilities];
    }

    _allAppMetadata = [self getJSON];
    _publicAppMetaData = [self generatePublicConsoleMetadata];

    return self;
}

- (IBAction)exit:(id)sender {
    [[NSApplication sharedApplication] endSheet:_configureSheet];
}

- (IBAction)muteTapped:(NSButton *)sender {
    BOOL state = ([sender state] == NSOnState)? YES : NO;
    [_saver setMuted:state];

    [[NSUserDefaults userDefaults] setBool:state forKey:MuteDefault];
    [[NSUserDefaults userDefaults] synchronize];
}

- (IBAction)skipClicked:(id)sender {
    [[NSUserDefaults userDefaults] removeObjectForKey:ProgressDefault];
    [[NSUserDefaults userDefaults] removeObjectForKey:StreamValueProgressDefault];
    [[NSUserDefaults userDefaults] removeObjectForKey:MovieNameDefault];
    [[NSUserDefaults userDefaults] removeObjectForKey:FileMD5Default];
    [[NSUserDefaults userDefaults] removeObjectForKey:YoutubeURLDefault];
    [[NSUserDefaults userDefaults] synchronize];
}

- (IBAction)streamVideoTapped:(id)sender {
    BOOL state = ([sender state] == NSOnState)? YES : NO;
    [[NSUserDefaults userDefaults] setBool:state forKey:StreamDefault];

    [[NSUserDefaults userDefaults] removeObjectForKey:@"MovieNameDefault"];
    [[NSUserDefaults userDefaults] removeObjectForKey:@"FileMD5Default"];
    [[NSUserDefaults userDefaults] removeObjectForKey:@"StreamValueProgressDefault"];
    [[NSUserDefaults userDefaults] synchronize];
}

- (NSWindow *)configureWindow {
    if (!_configureSheet) {
        [NSBundle loadNibNamed:@"Settings" owner:self];
    }
    return _configureSheet;
}

- (NSArray *)appMetadata {
    return _publicAppMetaData;
}

- (void)awakeFromNib {
    NSString *tweetbotBundle = @"com.tapbots.TweetbotMac";
    NSString *tweetBotPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:tweetbotBundle];
    _installedTweetbot = (tweetBotPath != nil);

    if ([[NSUserDefaults userDefaults] valueForKey:MuteDefault]) {
        BOOL muted = [[NSUserDefaults userDefaults] boolForKey:MuteDefault];
        [_muteCheckBox setState:(muted)? NSOnState : NSOffState];
    }

    if ([[NSUserDefaults userDefaults] valueForKey:StreamDefault]) {
        BOOL shouldStream = [[NSUserDefaults userDefaults] boolForKey:StreamDefault];
        [_streamCheckBox setState:(shouldStream)? NSOnState : NSOffState];
    }

    [_popupButtonCell selectItemAtIndex:_sizeIndex];
}

- (IBAction)qualityChanged:(NSPopUpButton *)sender {
    _sizeIndex = [sender selectedTag];
    [[NSUserDefaults userDefaults] setInteger:_sizeIndex forKey:SizeIndexDefault];
}

- (NSArray *)availableYoutubeSizes {
    NSMutableArray *sizes = [NSMutableArray array];
    for (NSInteger i = _sizeIndex; i < YoutubeSizes.count; i++) {
        [sizes addObject:YoutubeSizes[i]];
    }
    return sizes;
}

- (NSArray *)getJSON {
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"metadata" ofType:@"json"];
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"Data Error : %@", error.localizedDescription);
        return nil;
    }

    NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"JSON Error : %@", error.localizedDescription);
        return nil;
    }

    return json;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _allAppMetadata.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _allAppMetadata[row][@"console"];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableColumn == _titleTableColumn) {
        [cell setTitle:_allAppMetadata[row][@"console"]];
        [cell setAction:@selector(checkedConsole:)];
        [cell setTarget:self];
        [cell setTag:row];
        if ([_consoleAvailabilities[row] boolValue]) {
            [cell setState:NSOnState];
        } else {
            [cell setState:NSOffState];
        }
        
    } else {
        NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)[_allAppMetadata[row][@"movies"] count] ];
        [cell setTitle:count];
    }
}

- (void)checkedConsole:(NSTableView *)tableView {
    NSInteger index = [tableView selectedTag];
    if ([_consoleAvailabilities[index] boolValue]) {
        [_consoleAvailabilities replaceObjectAtIndex:index withObject:@(NO)];
    } else {
        [_consoleAvailabilities replaceObjectAtIndex:index withObject:@(YES)];
    }

    [[NSUserDefaults userDefaults] setObject:_consoleAvailabilities forKey:AvailabilitiesDefault];
    _publicAppMetaData = [self generatePublicConsoleMetadata];

    NSIndexSet *row = [NSIndexSet indexSetWithIndex:index];
    NSIndexSet *column = [NSIndexSet indexSetWithIndex:0];
    [tableView reloadDataForRowIndexes:row columnIndexes:column];
}

- (NSArray *)generatePublicConsoleMetadata {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < _allAppMetadata.count; i++) {
        if ([_consoleAvailabilities[i] boolValue]) {
            [array addObject:_allAppMetadata[i]];
        }
    }

    // return non-mutable for faster lookup
    return [NSArray arrayWithArray:array];
}

- (NSMutableArray *)initialAvailabilities {
    return [@[
        @(YES), //NES
        @(YES), //SNES
        @(YES), //N64
        @(YES), //GameCube
        @(NO),  //Wii
        @(YES), //GameBoy
        @(NO),  //VirtualBoy
        @(YES), //GBA
        @(NO),  //DS
        @(YES), //SMS
        @(YES), //MegaDrive
        @(NO),  //Saturn
        @(YES), //PlayStation
        @(NO),  //PCEngine
        @(NO),  //Arcade
        @(YES), //Computer
        @(NO),  //Atari2600
        @(NO),  //Lynx
        @(NO),  //Colecovision
     ] mutableCopy];
}

// About section

- (IBAction)aboutTapped:(NSButton *)sender {
    _showingAbout = !_showingAbout;
    if (_showingAbout) {
        [sender setTitle:@"Back"];
    } else {
        [sender setTitle:@"About"];
    }
    CGRect _aboutFrame = _aboutView.frame;
    CGRect _settingsFrame = _settingsView.frame;
    [[_aboutView animator] setFrame:_settingsFrame];
    [[_settingsView animator] setFrame:_aboutFrame];
}

- (IBAction)githubTapped:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/orta/"]];
}

- (IBAction)twitterTapped:(id)sender {

    if (_installedTweetbot) {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/open"];
        [task setArguments:@[ @"tweetbot://orta/user_profile/orta"]];
        [task launch];

    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://twitter.com/orta/"]];
    }
}

- (IBAction)ortaTapped:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://orta.github.io/"]];
}


@end

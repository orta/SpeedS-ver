//
//  ScreenSaverConfig.m
//  GamesScreensaver
//
//  Created by orta therox on 11/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ScreenSaverConfig.h"
#import "NSUserDefaults+ScreenSaverDefaults.h"

static NSArray *YoutubeSizes;
static NSString *SizeIndexDefault = @"SizeIndexDefault";
static NSString *AvailabilitiesDefault = @"AvailabilitiesDefault";

@implementation ScreenSaverConfig {
    IBOutlet NSWindow *_configureSheet;
    IBOutlet NSButton *_okButton;
    IBOutlet NSPopUpButtonCell *_popupButtonCell;
    IBOutlet NSTableColumn *_titleTableColumn;

    NSInteger _sizeIndex;
    NSMutableArray *_consoleAvailabilities;

    NSArray *_allAppMetadata;
    NSArray *_publicAppMetaData;
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
        if (_consoleAvailabilities.count < 1) {
            [_consoleAvailabilities replaceObjectAtIndex:index withObject:@(NO)];
        }
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

@end

//
//  ScreenSaverConfig.m
//  GamesScreensaver
//
//  Created by orta therox on 11/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "ScreenSaverConfig.h"

static NSArray *YoutubeSizes;
static NSString *SizeIndexDefault = @"SizeIndexDefault";

@implementation ScreenSaverConfig {
    IBOutlet NSWindow *_configureSheet;
    IBOutlet NSButton *_okButton;
    IBOutlet NSPopUpButtonCell *_popupButtonCell;
    IBOutlet NSTableColumn *_titleTableColumn;
    NSInteger _sizeIndex;
}

- (id)init {
    self = [super init];
    if (!self) return nil;

    _appMetadata = [self getJSON];
    YoutubeSizes = @[@"hd1080", @"hd720", @"highres", @"medium", @"small"];

    if ([[NSUserDefaults standardUserDefaults] valueForKey:SizeIndexDefault]) {
        _sizeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:SizeIndexDefault];
    } else {
        _sizeIndex = 1;
    }

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

- (void)awakeFromNib {
    [_popupButtonCell selectItemAtIndex:_sizeIndex];
}

- (IBAction)qualityChanged:(NSPopUpButton *)sender {
    _sizeIndex = [sender selectedTag];
    [[NSUserDefaults standardUserDefaults] setInteger:_sizeIndex forKey:SizeIndexDefault];
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
    return _appMetadata.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return _appMetadata[row][@"console"];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableColumn == _titleTableColumn) {
        [cell setTitle:_appMetadata[row][@"console"]];
        [cell setAction:@selector(checkedConsole:)];
        [cell setTarget:self];
        [cell setTag:row];
    } else {
        NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)[_appMetadata[row][@"movies"] count] ];
        [cell setTitle:count];
    }
}

- (void)checkedConsole:(NSTableView *)tableView {

}

@end

//
//  CRTModePlugInLoader.h
//  CRTMode
//
//  Created by orta therox on 19/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <QuartzCore/CoreImage.h>

@interface CRTModePlugInLoader : NSObject <CIPlugInRegistration>

- (BOOL)load:(void *)host;

@end

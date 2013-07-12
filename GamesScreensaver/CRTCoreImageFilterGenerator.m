//
//  CRTCoreImageFilterGenerator.m
//  SpeedS@ver
//
//  Created by Orta on 12/07/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "CRTCoreImageFilterGenerator.h"
#import <QuartzCore/QuartzCore.h>

@implementation CRTCoreImageFilterGenerator

+ (NSArray *)coreImageFilters
{
//    CIFilter *filterColorMatrix = [CIFilter filterWithName:@"CIColorMatrix"];
//    CIVector *greenVector = [CIVector vectorWithX:1 Y:0 Z:0 W:0];
//    [filterColorMatrix setValue:greenVector forKey:@"inputGVector"];
//

//    CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
//    [exposureFilter setDefaults];
//    [exposureFilter setValue:[NSNumber numberWithDouble:-1.25] forKey:@"inputEV"];
    CIFilter *saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
    [saturationFilter setDefaults];
    [saturationFilter setValue:[NSNumber numberWithDouble:0.35] forKey:@"inputSaturation"];
    CIFilter *gloomFilter = [CIFilter filterWithName:@"CIGloom"];
    [gloomFilter setDefaults];
    [gloomFilter setValue:[NSNumber numberWithDouble:0.75] forKey:@"inputIntensity"];

//    CIFilter *filterBloom = [CIFilter filterWithName:@"CIBloom"];
//    [filterBloom setValue:[NSNumber numberWithDouble:5.0] forKey:@"inputRadius"];
//    [filterBloom setValue:[NSNumber numberWithDouble:2.0] forKey:@"inputIntensity"];

    return @[saturationFilter, gloomFilter];

}

@end

//
//  CRTModeFilter.m
//  CRTMode
//
//  Created by orta therox on 19/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import "CRTModeFilter.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation CRTModeFilter

static CIKernel *_CRTModeFilterKernel = nil;

- (id)init
{
    if(!_CRTModeFilterKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"CRTModeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"CRTModeFilterKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];

		_CRTModeFilterKernel = kernels[0];
    }
    return [super init];
}

- (CGRect)regionOf:(int)sampler  destRect:(CGRect)rect  userInfo:(NSNumber *)radius
{
    return CGRectInset(rect, -[radius floatValue], 0);
}

- (NSDictionary *)customAttributes
{
    return @{
        @"inputCenter":@{
            kCIAttributeDefault:[CIVector vectorWithX:200.0 Y:200.0],
            kCIAttributeType:kCIAttributeTypePosition,
        },
        @"inputWidth":@{
            kCIAttributeMin:@1.00,
            kCIAttributeSliderMin:@1.00,
            kCIAttributeSliderMax:@1000.00,
            kCIAttributeDefault:@400.00,
            kCIAttributeIdentity:@400.00,
            kCIAttributeType:kCIAttributeTypeDistance,
        },
        @"inputAmount":@{
            kCIAttributeMin:@0.00,
            kCIAttributeSliderMin:@0.00,
            kCIAttributeSliderMax:@2.00,
            kCIAttributeDefault:@0.50,
            kCIAttributeIdentity:@0.00,
            kCIAttributeType:kCIAttributeTypeDistance,
        },
    };
}

// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    float radius;
    CISampler *src;
    
    src = [CISampler samplerWithImage:inputImage];
    radius = [inputWidth floatValue] * 0.5;
    return [self apply:_CRTModeFilterKernel, src,
        [NSNumber numberWithFloat:[inputCenter X]],
        [NSNumber numberWithFloat:1.0 / radius],
        [NSNumber numberWithFloat:radius],
        [NSNumber numberWithFloat:1.0 / pow(10.0, [inputAmount floatValue])],
	    kCIApplyOptionDefinition, [[src definition] insetByX:-radius Y:-radius],
	    kCIApplyOptionUserInfo, [NSNumber numberWithFloat:radius], nil];
}

@end

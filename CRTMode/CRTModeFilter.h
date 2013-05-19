//
//  CRTModeFilter.h
//  CRTMode
//
//  Created by orta therox on 19/05/2013.
//  Copyright (c) 2013 Orta. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CRTModeFilter : CIFilter {
    CIImage      *inputImage;
    CIVector     *inputCenter;
    NSNumber     *inputWidth;
    NSNumber     *inputAmount;
}

@end

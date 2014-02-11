//
//  FYMyPlane.m
//  FYGamePlane
//
//  Created by xu lingyi on 14-2-8.
//  Copyright (c) 2014年 xuly. All rights reserved.
//

#import "FYMyPlane.h"

#define kHitPaddingLeft         15.0
#define kHitPaddingRight        15.0
#define kHitPaddingTop          5.0
#define kHitPaddingBottom       22.0

@implementation FYMyPlane

- (CGRect)myPlaneRect
{
    CGRect rect = self.frame;
    rect.origin.x += kHitPaddingLeft;
    rect.origin.y += kHitPaddingTop;
    rect.size.width -= (kHitPaddingLeft + kHitPaddingRight);
    rect.size.height -= (kHitPaddingTop + kHitPaddingBottom);
    return rect;
}

@end

//
//  FYData.m
//  FYGamePlane
//
//  Created by xu lingyi on 14-2-11.
//  Copyright (c) 2014年 xuly. All rights reserved.
//

#import "FYData.h"

static FYData *kDataInstance = nil;

@implementation FYData

- (id)init
{
    if (self = [super init]) {
        self.yourScore = 0;
        self.yourTime = 0;
    }
    return self;
}

+ (FYData *)shareData
{
    if (kDataInstance == nil) {
        kDataInstance = [[FYData alloc] init];
    }
    return kDataInstance;
}


@end

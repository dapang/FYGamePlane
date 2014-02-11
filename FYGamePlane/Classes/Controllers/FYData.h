//
//  FYData.h
//  FYGamePlane
//
//  Created by xu lingyi on 14-2-11.
//  Copyright (c) 2014年 xuly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYData : NSObject

@property (assign, nonatomic) NSUInteger yourScore;
@property (assign, nonatomic) NSUInteger yourTime;

+ (FYData *)shareData;

@end

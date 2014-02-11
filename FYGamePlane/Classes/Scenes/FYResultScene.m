//
//  FYResultScene.m
//  FYGamePlane
//
//  Created by xu lingyi on 14-2-10.
//  Copyright (c) 2014年 xuly. All rights reserved.
//

#import "FYResultScene.h"
#import "FYMainScene.h"
#import "FYData.h"

@implementation FYResultScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        [self showResult];
    }
    
    return self;
}

- (void)showResult
{
    NSString *message = [NSString stringWithFormat:@"你坚持了 %d 秒,得分 %d ",[FYData shareData].yourTime,[FYData shareData].yourScore];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"游戏结束" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"重新开始", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SKAction *gotoPlayAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
        SKScene *scene = [FYMainScene sceneWithSize:self.size];
        [self.view presentScene:scene transition:reveal];
    }];
    [self runAction:gotoPlayAction];
}

@end

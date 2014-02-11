//
//  FYMainScene.m
//  FYGamePlane
//
//  Created by xu lingyi on 14-2-7.
//  Copyright (c) 2014年 xuly. All rights reserved.
//

#import "FYMainScene.h"
#import "FYResultScene.h"
#import "FYData.h"

#define kBgImageHeight  600
#define kBgSpeed        10
#define kScorePerPlane  100

#define kCloudSpeedMin      5
#define kCloudSpeedMax      15

#define kEnemySpeedMin      3
#define kEnemySpeedMax      5

#define kMyPlaneMask        1
#define kEnemyPlaneMask     2
#define kBulletMask         3

@interface FYMainScene()

@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) SKSpriteNode *bg1;
@property (strong, nonatomic) SKSpriteNode *bg2;

@property (strong, nonatomic) SKNode *myPlaneNode;

@property (strong, nonatomic) SKSpriteNode *bullet;
@property (assign, nonatomic) float bulletSpeed;

@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (assign, nonatomic) NSUInteger score;
@property (strong, nonatomic) SKLabelNode *playtimeLabel;
@property (assign, nonatomic) NSUInteger playtime;

@end

@implementation FYMainScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [self startGame];
    }
    
    return self;
}

/**
 *
 *
 */
- (void)startGame
{
    [self removeAllActions];
    [self removeAllChildren];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    self.score = 0;
    self.playtime = 0;
    self.bulletSpeed = 0.5;
    
    self.bg1 = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
    self.bg2 = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
    
    self.bg1.position = CGPointMake(CGRectGetMidX(self.frame), kBgImageHeight/2);
    self.bg1.zPosition = 0;
    self.bg2.position = CGPointMake(CGRectGetMidX(self.frame), kBgImageHeight/2+kBgImageHeight);
    self.bg2.zPosition = 0;
    
    [self addChild:self.bg1];
    [self addChild:self.bg2];
    
    SKSpriteNode *myPlane = [SKSpriteNode spriteNodeWithImageNamed:@"myplane"];
    SKSpriteNode *myPropeller = [SKSpriteNode spriteNodeWithImageNamed:@"propeller1"];
    SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"propeller1"];
    SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"propeller2"];
    SKAction *rotateAction = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.01];
    SKAction *rotateForever = [SKAction repeatActionForever:rotateAction];
    [myPropeller runAction:rotateForever];
    myPropeller.position = CGPointMake(-1, myPlane.size.height/2-2);
    
    self.myPlaneNode = [SKNode node];
    [self.myPlaneNode addChild:myPlane];
    [self.myPlaneNode addChild:myPropeller];
    self.myPlaneNode.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    self.myPlaneNode.zPosition = 10;
    self.myPlaneNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:myPlane.size];
    self.myPlaneNode.physicsBody.allowsRotation = NO;
    self.myPlaneNode.physicsBody.categoryBitMask = kMyPlaneMask;
    self.myPlaneNode.physicsBody.contactTestBitMask = kEnemyPlaneMask;
    self.myPlaneNode.physicsBody.collisionBitMask = kEnemyPlaneMask;
    [self addChild:self.myPlaneNode];
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    self.scoreLabel.fontSize = 20;
    self.scoreLabel.fontColor = [UIColor blackColor];
    [self addChild:self.scoreLabel];
    
    self.playtimeLabel = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    self.playtimeLabel.fontSize = 20;
    self.playtimeLabel.fontColor = [UIColor blackColor];
    [self addChild:self.playtimeLabel];
    
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:0.3],[SKAction performSelector:@selector(shoot) onTarget:self]]]] withKey:@"shootAction"];
    
    /* 不使用 CADisplayLink */
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0 target:self selector:@selector(mainLoop) userInfo:nil repeats:YES];
    
}

/**
 *
 *  在SpriteKit中添加手势
 *
 */
- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panRecognizer];
}

/**
 *
 *  操作飞机
 *
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognier
{
    CGPoint translation = [recognier translationInView:self.view];
    CGFloat x = self.myPlaneNode.position.x + translation.x;
    CGFloat y = self.myPlaneNode.position.y - translation.y;
    
    x = fminf(fmaxf(x, self.myPlaneNode.frame.size.width/2), self.frame.size.width-self.myPlaneNode.frame.size.width/2);
    y = fminf(fmaxf(y, self.myPlaneNode.frame.size.width/2), self.frame.size.height-self.myPlaneNode.frame.size.width/2);
    
    self.myPlaneNode.position = CGPointMake(x, y);
    
    [recognier setTranslation:CGPointMake(0.0, 0.0) inView:self.view];
}

/**
 *
 *  游戏主循环
 *
 */
- (void)mainLoop
{
    self.playtime++;
    
    [self backgroundLoop];
    
    if (0 == arc4random() % 500)
    {
        [self newRandomCloud];
    }
    
    CGFloat level = 1.1 - powf(0.98, (self.playtime/100));
    
    if (0 == arc4random() % (int)(6 / level))
    {
        [self newRandomEnemy];
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %lu",(unsigned long)self.score];
    self.scoreLabel.position = CGPointMake(self.scoreLabel.frame.size.width/2+2,self.size.height-26);
    self.scoreLabel.zPosition = 10000;
    self.playtimeLabel.text = [NSString stringWithFormat:@"Time: %lus",(unsigned long)self.playtime/100];
    self.playtimeLabel.position = CGPointMake(self.scoreLabel.frame.size.width+2+self.playtimeLabel.frame.size.width/2+2,self.size.height-26);
    self.scoreLabel.zPosition = 10000;
}

/**
 *
 *  背景循环
 *
 */
- (void)backgroundLoop
{
    if (self.bg1.position.y == kBgImageHeight/2 && self.bg2.position.y == (kBgImageHeight/2+kBgImageHeight)) {
        SKAction *bg1Action = [SKAction moveToY:(kBgImageHeight/2-kBgImageHeight) duration:kBgSpeed];
        [self.bg1 runAction:bg1Action];
        SKAction *bg2Action = [SKAction moveToY:(kBgImageHeight/2) duration:kBgSpeed];
        [self.bg2 runAction:bg2Action];
    } else if (self.bg1.position.y == (kBgImageHeight/2+kBgImageHeight) && self.bg2.position.y == kBgImageHeight/2){
        SKAction *bg1Action = [SKAction moveToY:(kBgImageHeight/2) duration:kBgSpeed];
        [self.bg1 runAction:bg1Action];
        SKAction *bg2Action = [SKAction moveToY:(kBgImageHeight/2-kBgImageHeight) duration:kBgSpeed];
        [self.bg2 runAction:bg2Action];
    } else if (self.bg1.position.y == (kBgImageHeight/2-kBgImageHeight)){
        self.bg1.position = CGPointMake(self.frame.size.width/2, (kBgImageHeight/2+kBgImageHeight));
    }  else if (self.bg2.position.y == (kBgImageHeight/2-kBgImageHeight)){
        self.bg2.position = CGPointMake(self.frame.size.width/2, (kBgImageHeight/2+kBgImageHeight));
    }
}

/**
 *
 *  随机生成云
 *
 */
- (void)newRandomCloud
{
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    CGFloat x = (arc4random() % (int)(self.frame.size.width + cloud.frame.size.width)) - cloud.frame.size.width;
    cloud.position = CGPointMake(x, self.frame.size.height+cloud.frame.size.height/2);
    
    CGFloat speed = arc4random() % (kCloudSpeedMax - kCloudSpeedMin) + kCloudSpeedMin;
    
    SKAction *cloudAction = [SKAction moveToY:(0.0-cloud.frame.size.height) duration:speed];
    [cloud runAction:cloudAction completion:^(void){
        [cloud removeFromParent];
    }];
    cloud.zPosition = (arc4random() % 20) + 1;
    [self addChild:cloud];
}

/**
 *
 *  随机生成敌机
 *
 */
- (void)newRandomEnemy
{
    SKSpriteNode *enemyPlane = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"enemyplane%d",(arc4random() % 2 + 1)]];
    SKSpriteNode *enemyPropeller = [SKSpriteNode spriteNodeWithImageNamed:@"enemypropeller1"];
    SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"enemypropeller1"];
    SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"enemypropeller2"];
    SKAction *rotateAction = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.01];
    SKAction *rotateForever = [SKAction repeatActionForever:rotateAction];
    [enemyPropeller runAction:rotateForever];
    enemyPropeller.position = CGPointMake(0, -enemyPlane.size.height/2);
    SKNode *enemyPlaneNode = [SKNode node];
    CGFloat x = (arc4random() % (int)(self.size.width - enemyPlane.size.width)) + enemyPlane.frame.size.width/2;
    enemyPlaneNode.position = CGPointMake(x, self.size.height+enemyPlane.size.height/2);
    [enemyPlaneNode addChild:enemyPlane];
    [enemyPlane addChild:enemyPropeller];
    CGFloat speed = arc4random() % (kEnemySpeedMax - kEnemySpeedMin) + kEnemySpeedMin;
    SKAction *enemyAction = [SKAction moveToY:0-enemyPlane.size.height/2 duration:speed];
    [enemyPlaneNode runAction:enemyAction completion:^(void){
        [enemyPlaneNode removeFromParent];
    }];
    enemyPlaneNode.zPosition = 10;
    enemyPlaneNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemyPlane.size];
    enemyPlaneNode.physicsBody.dynamic = NO;
    enemyPlaneNode.physicsBody.categoryBitMask = kEnemyPlaneMask;
    enemyPlaneNode.physicsBody.contactTestBitMask = kBulletMask;
    enemyPlaneNode.physicsBody.collisionBitMask = kBulletMask;
    [self addChild:enemyPlaneNode];
}

/**
 *
 *  发射子弹
 *
 */
- (void)shoot
{
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    bullet.position = CGPointMake(self.myPlaneNode.position.x, self.myPlaneNode.position.y + self.bullet.size.height+30);
    bullet.zPosition = 1;
    bullet.scale = 0.8;
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
    bullet.physicsBody.allowsRotation = NO;
    bullet.physicsBody.categoryBitMask = kBulletMask;
    bullet.physicsBody.contactTestBitMask = kEnemyPlaneMask;
    bullet.physicsBody.collisionBitMask = kEnemyPlaneMask;
    
    SKAction *action = [SKAction moveToY:self.frame.size.height+bullet.size.height duration:self.bulletSpeed];
    SKAction *remove = [SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[action,remove]]];
    
    [self addChild:bullet];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kEnemyPlaneMask && contact.bodyB.categoryBitMask == kBulletMask)
    {
        [contact.bodyA.node runAction:[SKAction removeFromParent]];
        [contact.bodyB.node runAction:[SKAction removeFromParent]];
        [self boombByPositionX:contact.bodyA.node.position.x positionY:contact.bodyA.node.position.y];
        self.score += kScorePerPlane;
    }
    if (contact.bodyA.categoryBitMask == kBulletMask && contact.bodyB.categoryBitMask == kEnemyPlaneMask)
    {
        [contact.bodyB.node runAction:[SKAction removeFromParent]];
        [contact.bodyA.node runAction:[SKAction removeFromParent]];
        [self boombByPositionX:contact.bodyB.node.position.x positionY:contact.bodyB.node.position.y];
        self.score += kScorePerPlane;
    }
    if ((contact.bodyA.categoryBitMask == kMyPlaneMask && contact.bodyB.categoryBitMask == kEnemyPlaneMask) || (contact.bodyB.categoryBitMask == kMyPlaneMask && contact.bodyA.categoryBitMask == kEnemyPlaneMask))
    {
        [contact.bodyB.node runAction:[SKAction removeFromParent]];
        [contact.bodyA.node runAction:[SKAction removeFromParent]];
        [self boombByPositionX:contact.bodyA.node.position.x positionY:contact.bodyA.node.position.y];
        [self boombByPositionX:contact.bodyB.node.position.x positionY:contact.bodyB.node.position.y];
        
        [self removeActionForKey:@"shootAction"];
        [self.timer invalidate];
        self.timer = nil;
        [FYData shareData].yourScore = self.score;
        [FYData shareData].yourTime = (int)self.playtime/100;
        
        SKAction *gotoResultAction = [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition fadeWithDuration:2.0];
            SKScene *scene = [FYResultScene sceneWithSize:self.size];
            [self.view presentScene:scene transition:reveal];
        }];
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],gotoResultAction]]];
    }
}

/**
 *
 *  爆炸效果
 *
 */
- (void)boombByPositionX:(CGFloat)posX positionY:(CGFloat)posY
{
    SKEmitterNode *boomb = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"bombParticle" ofType:@"sks"]];
    boomb.particleLifetime = 1.0;
    boomb.position = CGPointMake(posX,posY);
    boomb.zPosition = 10;
    [self addChild:boomb];
}

@end

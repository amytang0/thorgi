//
//  Cat.m
//  My-User-Input-Project
//
//  Created by Amy Tang on 10/31/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "Cat.h"


@interface Cat (PrivateMethods)
// declare private methods here
@end

@implementation Cat
@synthesize health, points, speed, numFrames;
@synthesize direction;
@synthesize moveAction;
@synthesize velocity;
@synthesize name;
-(id) init
{
    self = [super init];
	if (self)
	{
	}
	return self;
}

-(id) initWithAnimatedCat
{
   // CCLOG(@"BasicCat initWithAnimatedCat called");
    if ((self = [super initWithSpriteFrameName:@"frontcat1.png"])) {
        health = 1;
        points = 2;
        speed = 1.5f;
        numFrames = 3;
        self.name = @"";
    }
    return self;
}

-(void) setMoveDirection: (NSString*)d
{
    if ([self.direction isEqualToString:d]) {
        return;
    }
    
    [self stopAction:self.moveAction];
    
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
       
    for (int i = 1; i <= self.numFrames; i++){
        NSString *fileName = [NSString stringWithFormat:@"%@%@cat%d.png",d,self.name,i];
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          fileName]];
        
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    self.moveAction = [CCRepeatForever actionWithAction:
                      [CCAnimate actionWithAnimation:walkAnim]];
    [self runAction:self.moveAction];
    self.direction = d;
}

-(void) onEnter
{
	[super onEnter];
    
	// add init code here where you need to use the self.parent reference
	// generally recommended to run node initialization here
}

-(void) cleanup
{
	[super cleanup];
    
	// any cleanup code goes here
	
	// specifically release/nil any references that could cause retain cycles
	// since dealloc might not be called if this class retains another node that is
    // either a sibling or in a different branch of the node hierarchy
}

-(void) dealloc
{
	// uncomment if you're not using ARC (ahem, make that: *still* not using ARC ...)
	//[super dealloc];
	
	// if you suspect a memory leak, put a breakpoint here to see if the node gets deallocated
	NSLog(@"dealloc: %@", self);
}

// scheduled update method
-(void) update:(ccTime)delta
{
}


@end

@implementation DashCat
CGFloat timeElapsed;
-(id) initWithAnimatedCat
{
   // CCLOG(@"DASHCAT INIT CALLED");
    if (self = [super initWithAnimatedCat]){
        self.speed = 5;
        self.points = 5;
        self.name=@"";
        timeElapsed = 0;
        [self schedule:@selector(dash) interval:5.0f];
        [self schedule:@selector(stop) interval:5.0f repeat:kCCRepeatForever  delay:1.0f];
    }
    return self;
}
-(void) dash
{
    if (self.speed == 0){
         self.speed = 6;
         self.color = ccGREEN;
    }    
}

-(void) stop
{
    if (self.speed != 0) {
        self.color= ccWHITE;
        self.speed = 0;
        self.velocity = b2Vec2(0,0);
    }
    
}
@end

@implementation WizardCat
@synthesize countdown;
-(id) initWithAnimatedCat
{
    
    if ((self = [super initWithSpriteFrameName:@"frontwizardcat1.png"])) {
        self.health = 1;
        self.points = 5;
        self.speed = 1;
        self.countdown = 3;
        //self.direction = @"";
         self.name = @"wizard";
        self.numFrames = 3;

        [self schedule:@selector(countDown) interval:1.0f];
    }
    return self;
}

-(void) countDown
{
    if(self.countdown < 0) [self resetCountDown];
    else {
      self.countdown--;
    }
}

-(void) resetCountDown
{
    self.countdown = 3;
}
@end

@implementation NyanCat
-(id) initWithAnimatedNyanCat
{
    self = [super initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"leftnyancat1.png"]];
    CCLOG(@"HEY NYAN INIT");
    
    if (self) {
        self.health = 3;
        self.points = 10;
        self.speed = 6;
        self.name = @"nyan";
        self.numFrames = 6;
        
        if (arc4random()%2 == 0) {
         //   self.flipX = YES;
            self.velocity = b2Vec2(-1.0f,0);
        } else {
          //  self.flipX = NO;
            self.velocity = b2Vec2(1.0f,0);
        }
    }
    return self;
    
}


@end

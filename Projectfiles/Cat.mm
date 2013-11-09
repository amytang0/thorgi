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
@synthesize health, points, speed;
@synthesize direction;
@synthesize moveAction;

-(id) init
{
	self = [super init];
	if (self)
	{
		// add init code here (note: self.parent is still nil here!)
        
		
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(id) initWithCatImage
{
    // This calls CCSprite's init. Basically this init method does everything CCSprite's init method does and then more
    if ((self = [super initWithFile:@"cat.png"]))
    {
        health = 1;
        points = 2;
        speed = 3.5;
        //properties work internally just like normal instance variables
    }
    return self;
}

-(id) initWithAnimatedCat
{
    if ((self = [super initWithSpriteFrameName:@"frontcat1.png"])) {
        health = 1;
        points = 2;
        speed = 2;
        direction = @"left";
        NSMutableArray *frontWalkAnimFrames = [NSMutableArray array];
        for (int i=1; i<=3; i++) {
            [frontWalkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"%@cat%d.png",direction,i]]];
        }
        
        CCAnimation *walkAnim = [CCAnimation
                                 animationWithSpriteFrames:frontWalkAnimFrames delay:0.1f];
        
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
       
       // self.position = ccp(winSize.width/2, winSize.height/2);
        moveAction = [CCRepeatForever actionWithAction:
                                [CCAnimate actionWithAnimation:walkAnim]];
        [self runAction:moveAction];
        //[spriteSheet addChild:sprite];
        //[self addChild:sprite];
    
    }
    return self;
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
@synthesize velocity;
-(id) initWithAnimatedCat
{
    if (self = [super initWithAnimatedCat]){
    //self.speed = 0;
        self.speed = 5;
        self.points = 5;
    timeElapsed = 0;
    //[self stopAction:self.moveAction];
  //  [self scheduleUpdate];
        [self schedule:@selector(dash) interval:5.0f];
        [self schedule:@selector(stop) interval:5.0f repeat:kCCRepeatForever  delay:2.0f];
    }
    return self;
}
-(void) dash
{

    if (self.speed == 0){
            CCLOG(@"Dash called");
    //[self runAction:self.moveAction];
         self.speed = 6;
         self.color = ccGREEN;
    }    
}

-(void) stop
{

    if (self.speed != 0) {
             CCLOG(@"Stop Dash called");
       self.color= ccWHITE;
    //[self stopAction:self.moveAction];
       self.speed = 0;
        velocity = b2Vec2(0,0);
    }
    
}

@end

@implementation WizardCat
@synthesize countdown;
-(id) initWithAnimatedCat
{
    if ((self = [super initWithSpriteFrameName:@"frontwizardcat1.png"])) {
        self.health = 2;
        self.points = 3;
        self.speed = 1;
        self.countdown = 3;
        self.direction = @"left";
        NSMutableArray *frontWalkAnimFrames = [NSMutableArray array];
        for (int i=1; i<=3; i++) {
            [frontWalkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"%@wizardcat%d.png",self.direction,i]]];
        }
        
        CCAnimation *walkAnim = [CCAnimation
                                 animationWithSpriteFrames:frontWalkAnimFrames delay:0.15f];
        
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // self.position = ccp(winSize.width/2, winSize.height/2);
        self.moveAction = [CCRepeatForever actionWithAction:
                      [CCAnimate actionWithAnimation:walkAnim]];
        [self runAction:self.moveAction];
        //[spriteSheet addChild:sprite];
        //[self addChild:sprite];
        
    }
    return self;
}


@end


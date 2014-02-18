//
//  Dog.m
//  My-User-Input-Project
//
//  Created by Amy Tang on 11/1/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "Dog.h"

#import "Box2D.h"

const float PTM_RATIO = 32.0f;

@interface Dog (PrivateMethods)
// declare private methods here
@end


@implementation Dog
@synthesize health, status;
@synthesize dogDirection, dogMoveAction;

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

-(id) initWithDogImage
{
    // This calls CCSprite's init. Basically this init method does everything CCSprite's init method does and then more
    if ((self = [super initWithSpriteFrameName:@"frontthorgi2.png"]))
    //if ((self = [super initWithFile:@"ship.png"]))
    {
        // Lives are stored as extra hearts in MGWU.
        health = [(NSNumber *)[MGWU objectForKey:@"hearts"] intValue] + BASE_HEALTH;
        CCLOG(@"HEALTH: %d", health);
        status = @"normal";
        //[self setScale:1.25f];
        
        
        
        //properties work internally just like normal instance variables
    }
    return self;
}

-(void) stopAction
{
    [self stopAction:self.dogMoveAction];
}


-(void) setMoveDirection: (NSString*)d
{
   // if ([self.dogDirection isEqualToString:d] && ![self.dogMoveAction isDone] ) {
   //     return;
   // }
    
    [self stopAction:self.dogMoveAction];
    
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    
    for (int i = 1; i <= 3; i++){
        NSString *fileName = [NSString stringWithFormat:@"%@thorgi%d.png",d,i];
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          fileName]];
        
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    self.dogMoveAction = [CCRepeatForever actionWithAction:
                       [CCAnimate actionWithAnimation:walkAnim]];
    [self runAction:self.dogMoveAction];
    self.dogDirection = d;
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

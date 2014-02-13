//
//  Bullet.m
//  Thorgi
//
//  Created by Amy Tang on 11/1/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "Bullet.h"

@interface Bullet (PrivateMethods)
// declare private methods here
@end

@implementation Bullet
@synthesize damage;

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

-(id) initWithBulletImage
{
    // This calls CCSprite's init. Basically this init method does everything CCSprite's init method does and then more
    if ((self = [super initWithFile:@"fire.png"]))
    {
        damage = 1;
        //properties work internally just like normal instance variables
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

@implementation WizardBullet

-(id) initWithBulletImage
{
    // This calls CCSprite's init. Basically this init method does everything CCSprite's init method does and then more
    if ((self = [super initWithBulletImage]))
    {
        self.damage = 1;
        self.color = ccGREEN;
        //properties work internally just like normal instance variables
    }
    return self;
}


@end

@implementation DerpBullet

-(id) initWithBulletImage
{
    // This calls WizardBullet's init.
    if ((self = [super initWithBulletImage]))
    {
        self.damage = 1;
        self.color = ccRED;
        //properties work internally just like normal instance variables
    }
    return self;
}


@end


@implementation MineBullet

-(id) initWithBulletImage
{
    // This calls CCSprite's init. Basically this init method does everything CCSprite's init method does and then more
    if ((self = [super initWithBulletImage]))
    {
        self.damage = 1;
        self.color = ccBLACK;
        //properties work internally just like normal instance variables
    }
    return self;
}


@end


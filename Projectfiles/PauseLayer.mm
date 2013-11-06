//
//  PauseLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/2/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "PauseLayer.h"

CCMenu * myMenu;

@interface PauseLayer (PrivateMethods)
// declare private methods here
@end

@implementation PauseLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	PauseLayer *layer = [[PauseLayer alloc] init];
	// add layer as a child to scene
	[scene addChild: layer z:0];
	// return the scene
	return scene;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		/*
        // Create some menu items
        CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"resumebutton.png"
                                                             selectedImage: @"resumebutton_selected.png"
                                                                    target:self
                                                                  selector:@selector(resume:)];
        
        CCMenuItemImage * menuItem2 = [CCMenuItemImage itemWithNormalImage:@"restartbutton.png"
                                                             selectedImage: @"restartbutton_selected.png"
                                                                    target:self
                                                                  selector:@selector(restart:)];
        
        CCMenuItemImage * menuItem3 = [CCMenuItemImage itemWithNormalImage:@"quitbutton.png"
                                                             selectedImage: @"quitbutton_selected.png"
                                                                    target:self
                                                                  selector:@selector(quit:)];
        
        CCMenuItemImage * menuItem4 = [CCMenuItemImage itemWithNormalImage:@"mutemusicbutton.png"
                                                             selectedImage: @"mutemusicbutton_selected.png"
                                                                    target:self
                                                                  selector:@selector(muteMusic:)];
        
        
        CCMenuItemImage * menuItem5 = [CCMenuItemImage itemWithNormalImage:@"mutesoundbutton.png"
                                                             selectedImage: @"mutesoundbutton_selected.png"
                                                                    target:self
                                                                  selector:@selector(muteSound:)];
        */
        
        CCMenuItemFont *menuItem1 = [CCMenuItemFont itemWithString:@"resume"];
           CCMenuItemFont *menuItem2 = [CCMenuItemFont itemWithString:@"restart"];
           CCMenuItemFont *menuItem3 = [CCMenuItemFont itemWithString:@"rmusic"];
           CCMenuItemFont *menuItem4 = [CCMenuItemFont itemWithString:@"mutemasdfae"];
           CCMenuItemFont *menuItem5 = [CCMenuItemFont itemWithString:@"mutee"];
        // Create a menu and add your menu items to it
        myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, nil];
        
        // Arrange the menu items Horizontally
        [myMenu alignItemsHorizontally];
        
        // add the menu to your scene
        [self addChild:myMenu];

        KKInput *input = [KKInput sharedInput];
		
        // uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
        self.isTouchEnabled = YES;
	}
	return self;
}

-(void) update:(ccTime)delta
{
    KKInput* input = [KKInput sharedInput];
    
    if ([input isAnyTouchOnNode:myMenu touchPhase:KKTouchPhaseBegan])
    {
        CCLOG(@"DETECTED TOUCH!");
    }
}

- (void) resume: (CCMenuItem  *) menuItem
{
	NSLog(@"The first menu was called RESUME");
    [[CCDirector sharedDirector] popScene];
}
- (void) restart: (CCMenuItem  *) menuItem 
{
	NSLog(@"The second menu was called RESTART");
}
- (void) quit: (CCMenuItem  *) menuItem 
{
	NSLog(@"The third menu was called QUIT");
}
- (void) muteMusic: (CCMenuItem  *) menuItem 
{
	NSLog(@"The fourth menu was called MUTEMUSIC");
}
- (void) muteSound: (CCMenuItem  *) menuItem 
{
	NSLog(@"The fifth menu was called MUTESOUND");
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


@end

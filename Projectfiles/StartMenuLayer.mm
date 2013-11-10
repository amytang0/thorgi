//
//  StartMenuLayer.m
//  PeevedPenguins
//
//  Created by Amy Tang on 10/12/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "StartMenuLayer.h"
#import "GameLayer.h"
#import "GameOverLayer.h"

@interface StartMenuLayer (PrivateMethods)
// declare private methods here
@end

@implementation StartMenuLayer 

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	StartMenuLayer *layer = [StartMenuLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init
{
	self = [super init];
	if (self)
	{
        CGRect appframe= [[UIScreen mainScreen] applicationFrame];
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"thorgitext.png"];
        CGSize size = sprite.textureRect.size;
        int padding = 30;
        sprite.scale = (1.0f*appframe.size.height-padding)/(1.0f*MAX(size.width, size.height));
        sprite.position = ccp(padding/2, appframe.size.width/2.0f);
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        sprite = [CCSprite spriteWithFile:@"dogofthundertext.png"];
        sprite.scale = (1.0f*appframe.size.height-padding)/(1.0f*MAX(size.width, size.height));
        sprite.position = ccp(sprite.scale*padding/2, appframe.size.width/2.0f - size.height + 10);
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        
        CCMenuItemImage *menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"thorgi-med.png" selectedImage:@"button.png" target:self selector:@selector(playGame:)];
        menuPlayButton.tag = 1; 
        
        // Create a menu and add your menu items to it
        CCMenu *myMenu = [CCMenu menuWithItems:menuPlayButton, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsHorizontally];
        myMenu.position = ccp(appframe.size.height/2, 65);
        
        // add the menu to your scene
        [self addChild:myMenu];
        
        self.isTouchEnabled = YES;
		
        // uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(void) playGame:(CCMenuItem *)sender 
{
    HUDLayer *hud = [HUDLayer node];
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] initWithHUD:hud]];
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
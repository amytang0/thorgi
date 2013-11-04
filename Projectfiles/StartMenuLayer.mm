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
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"menu-background.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        
        CCMenuItemImage *menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"button.png" selectedImage:@"button.png" target:self selector:@selector(playGame:)];
        menuPlayButton.tag = 1; 
        
        CCLabelTTF *level1label = [CCLabelTTF labelWithString:@"Level 1" fontName:@"Georgia-Bold" fontSize:25];
        CCLabelTTF *level2label = [CCLabelTTF labelWithString:@"Level 2" fontName:@"Georgia-Bold" fontSize:25];
        
        CCMenuItemLabel *menuLevel1Button  = [CCMenuItemLabel itemWithLabel:level1label target:self selector:@selector(playGame:)];
        menuLevel1Button.tag = 1; 
        
        CCMenuItemLabel *menuLevel2Button  = [CCMenuItemLabel itemWithLabel:level2label target:self selector:@selector(playGame:)];
        menuLevel2Button.tag = 2; 
        
        
        // Create a menu and add your menu items to it
        CCMenu * myMenu = [CCMenu menuWithItems:menuPlayButton, menuLevel1Button, menuLevel2Button, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsHorizontally];
        myMenu.position = ccp(230, 90);
        
        // add the menu to your scene
        [self addChild:myMenu];
        
		
        // uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(void) playGame:(CCMenuItem *)sender 
{
    if (sender.tag == 2) {
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameOverLayer alloc] init]];
        
    } else {
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] init]];
    }
    NSLog(@"Play the game");
    
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
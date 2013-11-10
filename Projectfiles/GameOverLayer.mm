//
//  GameOverLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/2/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "GameOverLayer.h"
#import "StartMenuLayer.h"

CCLabelTTF *score;

@interface GameOverLayer (PrivateMethods)
// declare private methods here
@end

@implementation GameOverLayer

+(id) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	GameOverLayer *layer = [GameOverLayer node];
    
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
        // Makes texture tiled background
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"texture3.png"];
        ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [texture setTexParameters:&params];
        CGRect r = [CCDirector sharedDirector].screenRectInPixels;
        CCSprite *bg = [[CCSprite alloc] initWithTexture:texture rect:r];
        [self addChild:bg z:-10];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            score = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Chalkduster" fontSize:22.0f];
        } else {
            score = [CCLabelTTF labelWithString:@"WOOOP!!" fontName:@"Chalkduster" fontSize:20.0f];
        }

        CCMenuItemImage *menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"button.png" selectedImage:@"ship.png" target:self selector:@selector(showStartScreen:)];
                
        // Create a menu and add your menu items to it
        CCMenu * myMenu = [CCMenu menuWithItems: menuPlayButton, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsVertically];
        
        // add the menu to your scene
        [self addChild:myMenu];
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
        self.isTouchEnabled = YES;
	}
	return self;
}


- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //UITouch* touch = [touches anyObject];
    //CCLOG(@"DETECTED TOUCH on gameOverlayer!");
    
}

-(void) showStartScreen:(CCMenuItem *)sender{
    NSLog(@"Show start screen");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[StartMenuLayer alloc] init]];
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
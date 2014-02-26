//
//  GoldLayer.m
//  Thorgi
//
//  Created by Amy Tang on 2/24/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "GoldLayer.h"

@interface GoldLayer (PrivateMethods)
// declare private methods here
@end

@implementation GoldLayer

-(id) init
{
	self = [super init];
	if (self)
	{
		// add init code here (note: self.parent is still nil here!)
		
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
        
        CCMenuItemFont *button1 = [CCMenuItemFont itemWithString:@"Buy 10" target:self selector:@selector(buyGold:)];
        button1.tag = 1;
        CCMenuItemFont *button2 = [CCMenuItemFont itemWithString:@"Buy 20" target:self selector:@selector(buyGold:)];
        button2.tag = 2;
        CCMenuItemFont *button3 = [CCMenuItemFont itemWithString:@"Buy 50" target:self selector:@selector(buyGold:)];
        button3.tag = 3;
        
        CCMenuItemFont *backButton = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector(goBack:)];
        backButton.tag = 4;
        
        
        CCMenu *firstRowMenu = [CCMenu menuWithItems:button1, button2, button3, nil];
        
        // Create a menu and add your menu items to it
        CCMenu *secondRowMenu = [CCMenu menuWithItems:backButton, nil];
        
        secondRowMenu.position = ccp(firstRowMenu.position.x, firstRowMenu.position.y-100);
        
        // Arrange the menu items vertically
        [firstRowMenu alignItemsVertically];
        [self addChild:firstRowMenu];
        [secondRowMenu alignItemsHorizontally];
        [self addChild:secondRowMenu];
        

	}
	return self;
}

-(void) goBack:(CCMenuItem *)sender
{
    //[[CCDirector sharedDirector] replaceScene: (CCScene*)[[StartMenuLayer alloc] init]];
    [[CCDirector sharedDirector] popScene];
    
}

-(void) buyGold:(CCMenuItem *)sender
{
    CCLOG(@"%d", sender.tag);
    int gold = 0;
    switch(sender.tag) {
        case 1:{
            gold = 10;
            [MGWU testBuyProduct:@"com.amytang.thorgi.gold10" withCallback:@selector(boughtProduct:) onTarget:self];
            
        }
        case 2:{
            gold = 20;
            [MGWU testBuyProduct:@"com.amytang.thorgi.gold20" withCallback:@selector(boughtProduct:) onTarget:self];
        }
        case 3:{
            gold = 50;
            [MGWU testBuyProduct:@"com.amytang.thorgi.gold50" withCallback:@selector(boughtProduct:) onTarget:self];
        }
        case 4:{
            
        }
        default:{
            
        }
    }
    [MGWU showMessage:@"Purchase successful" withImage:nil];
    
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

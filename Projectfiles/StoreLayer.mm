//
//  StoreLayer.m
//  Thorgi
//
//  Created by Amy Tang on 2/13/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "StoreLayer.h"

@interface StoreLayer (PrivateMethods)
// declare private methods here
@end

@implementation StoreLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	StoreLayer *layer = [StoreLayer node];
    
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
        NSNumber *gold = (NSNumber*)[MGWU objectForKey:@"coinCount"];
        
        CCLabelTTF *storeString = [CCLabelTTF labelWithString:@"Store" fontName:@"Chalkduster" fontSize:24.0f];
        storeString.position = ccp(appframe.size.height/2, appframe.size.width - 20);
        [self addChild:storeString];
        
        goldString = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Gold: %@", gold] fontName:@"Chalkduster" fontSize:20.0f];
        goldString.position = ccp(appframe.size.height/2, appframe.size.width - 60);
        [self addChild:goldString];

        CCMenuItemImage *button1 = [CCMenuItemImage itemWithNormalImage:@"thorgipose.png" selectedImage:@"thorgipose.png"  target:self selector:@selector(showPurchaseAlert:)];
        button1.tag = 1;
        
        CCMenuItemImage *button2 = [CCMenuItemImage itemWithNormalImage:@"thorgipose.png" selectedImage:@"thorgipose.png"  target:self selector:@selector(showPurchaseAlert:)];
         button2.tag = 2;
         CCMenuItemImage *button3 = [CCMenuItemImage itemWithNormalImage:@"thorgipose.png" selectedImage:@"thorgipose.png"  target:self selector:@selector(showPurchaseAlert:)];
         button3.tag = 3;
        
        // Create a menu and add your menu items to it
        CCMenu *myMenu = [CCMenu menuWithItems:button1, button2, button3, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsHorizontally];
        
        [self addChild:myMenu];
	}
	return self;
}

-(void) showPurchaseAlert:(CCMenuItem *)sender
{
    CCLOG(@"SENDER WAS: %@", sender);
    switch(sender.tag) {
        case 1:
            [self showPurchaseBox:sender name:@"Heart" description:@"It's purty cool." price:20];
            break;
        case 2:
            [self showPurchaseBox:sender name:@"Increase heart drop rate" description:@"It's purty cool2." price:200];
            break;
        case 3:
            [self showPurchaseBox:sender name:@"Increase coin drop rate" description:@"It's purty cool3." price:500];
            break;
        case 4:
            [self showPurchaseBox:sender name:@"Increase big bullets drop rate" description:@"It's purty cool4." price:500];
            break;
    }
}

// This shows the alert asking for username input.
- (IBAction)showPurchaseBox:(id)sender name:(NSString*)name description:(NSString*)description price:(int)price {
    
    NSNumber *coins = (NSNumber *)[MGWU objectForKey:@"coinCount"];
    int coinsInt = [coins intValue];
    if(price > coinsInt) {
        NSLog(@"YOU TOO POOR! %d %d", price, coinsInt);
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:name message:description delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alert.tag = price;
        [alert show];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:name message:description delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:[NSString stringWithFormat:@"Buy for %d coins", price], nil];
        alert.tag = price;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CCLOG(@"BLEH %d price:%d", buttonIndex, alertView.tag);
    NSInteger price = alertView.tag;
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
        NSLog(@"Button 1 was selected.");
    }
    else 
    {
        NSNumber *coins = (NSNumber *)[MGWU objectForKey:@"coinCount"];
        int coinsInt = [coins intValue];
        if(price > coinsInt) {
          NSLog(@"YOU TOO POOR! %d %d", price, coinsInt);
        } else {
            CCLOG(@"Yay, you bought %d, %d", price, coinsInt);
            coinsInt -= price;
            NSNumber *newCoins = [NSNumber numberWithInt:coinsInt];
            [MGWU setObject:newCoins forKey:@"coinCount"];
        }
    }
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

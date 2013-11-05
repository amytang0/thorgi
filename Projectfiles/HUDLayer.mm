//
//  HUDLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

#import "GameLayer.h"

#define PADDING_TOP 20.0f

CCLabelTTF *scoreString;
CCLabelTTF *livesString;
  NSMutableArray *hearts;

@interface HUDLayer (PrivateMethods)
// declare private methods here
@end


@implementation HUDLayer

-(id) init
{
	self = [super init];
	if (self)
	{
        CCLOG(@"HUDLAYER INIT");
        hearts = [[NSMutableArray alloc] init];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            scoreString = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Arial" fontSize:22.0f];
        } else {
            scoreString = [CCLabelTTF labelWithString:@"WOOOP!!" fontName:@"Arial" fontSize:16.0f];
        }
        scoreString.position = ccp(winSize.width* 0.5, winSize.height - PADDING_TOP);
        [self addChild:scoreString];
        
        CCLabelTTF *menu = [CCLabelTTF labelWithString:@"menu" fontName:@"Arial" fontSize:16.0f];
        menu.position =  ccp(winSize.width* 0.9, winSize.height - PADDING_TOP);
        [self addChild:menu];
        /*
        livesString = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Arial" fontSize:16.0f];
        livesString.position = ccp(winSize.width*.15, winSize.height * .9);
        [self addChild:livesString];
         */
       // [self addChild:hearts];

        
        
    }
    
	return self;
}

-(void)setScoreString:(NSString *)string {
    scoreString.string = string;
}

-(void)setScore:(int) score {
    scoreString.string = [NSString stringWithFormat:@"Score: %d", score];
}

-(void) setLives:(int) health {
    //CCLOG(@"BLEH");
    livesString.string = [NSString stringWithFormat:@"Lives: %d", health];
    if (abs([hearts count]) == health)
        return;
   
    [self removeChildrenInArray:hearts cleanup:NO];
    
    hearts = [[NSMutableArray alloc] init];
    

    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint position = ccp(winSize.width*.05, winSize.height - PADDING_TOP);
    for (int i = 0; i < health; i++){
        CCSprite *heart = [CCSprite spriteWithFile:@"heart.png"];
        heart.position = position;
        [hearts addObject:heart];
        [self addChild:heart z:100];
        position = ccpAdd(position,ccp(20,0));
    }
}

-(void) playGame:(CCMenuItem *)sender
{

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

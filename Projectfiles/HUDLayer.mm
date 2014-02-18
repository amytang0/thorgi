//
//  HUDLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

#import "GameLayer.h"
#import "PauseLayer.h"
#import "GameOverLayer.h"


#define PADDING_TOP 20.0f
#define HEIGHT 25.0f


@interface HUDLayer (PrivateMethods)
// declare private methods here

@end


@implementation HUDLayer

-(id) init
{
	self = [super initWithColor:ccc4(255,255,255,0)];
	if (self)
	{
        CCLOG(@"HUDLAYER INIT");
        lives = [[NSMutableArray alloc] init];
        score = 0;
        gold = (NSNumber*)[MGWU objectForKey:@"coinCount"];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        [self setContentSize:CGSizeMake(winSize.width,HEIGHT*2)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            scoreString = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Chalkduster" fontSize:22.0f];
            scoreString.color = ccBLACK;
        } else {
            scoreString = [CCLabelTTF labelWithString:@"WOOOP!!" fontName:@"Chalkduster" fontSize:20.0f];
            scoreString.color = ccBLACK;
        }
        scoreString.position = ccp(winSize.width * 0.4f, HEIGHT/3.0f*2.0f);
        [self addChild:scoreString];
        
        [self setContentSize:CGSizeMake(winSize.width,HEIGHT*2)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            goldString = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Chalkduster" fontSize:22.0f];
            goldString.color = ccBLACK;
        } else {
            goldString = [CCLabelTTF labelWithString:@"WOOOP!!" fontName:@"Chalkduster" fontSize:20.0f];
            goldString.color = ccBLACK;
        }
        goldString.position = ccp(winSize.width * 0.7f, HEIGHT/3.0f*2.0f);
        [self addChild:goldString];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons.plist"];
        CCSpriteFrame *pauseButtonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"pause.png"];
        pauseButton = [[CCSprite alloc] initWithSpriteFrame:pauseButtonFrame];
        pauseButton.position =  ccp(winSize.width -30, HEIGHT/2.0f);
        [self addChild:pauseButton];

        int hearts = [(NSNumber *)[MGWU objectForKey:@"hearts"] intValue] + BASE_HEALTH;
        [self initLives:hearts];
        
        self.isTouchEnabled = YES;
    }
	return self;
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //  CCLOG(@"DETECTED TOUCH on hudlayer!");
    UITouch* touch = [touches anyObject];
    CGPoint touchStart = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // convert touch location to layer space
    touchStart = [self convertToNodeSpace:touchStart];
    [self handleMenuButton:touchStart];
    
}

-(void) handleMenuButton: (CGPoint)touch
{
    // CCLOG(@"TOUCH RECEIVED ON MENU IS %@", NSStringFromCGPoint(touch));
    CGRect rect = pauseButton.boundingBox;
    //if (CGRectContainsPoint(rect, touch)){
    if (fabsf(pauseButton.boundingBoxCenter.x - touch.x) <= rect.size.width/2 +10 &&
        fabsf(pauseButton.boundingBoxCenter.y - touch.y) <= rect.size.height/2 +10 )
    {
        [[CCDirector sharedDirector] pushScene: (CCScene*)[[PauseLayer alloc] initWithScore:score]];
       // [[CCDirector sharedDirector] replaceScene: (CCScene*)[[LocalScoreLayer alloc] init]]; //remove later
    }
}

-(void)setScore:(int) scoreP {
    scoreString.string = [NSString stringWithFormat:@"Score:%d", scoreP];
    score = scoreP;
}

-(void)setGold:(int) coinCount {
    NSNumber *coins = [[NSNumber alloc] initWithInt:coinCount];
    gold = coins;
    goldString.string = [NSString stringWithFormat:@"Gold:%@", gold];
}

-(void) initLives:(int)health {
    lives = [[NSMutableArray alloc] init];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    // CGPoint position = ccp(winSize.width*.05, winSize.height - PADDING_TOP);
    // CGPoint position = ccp(winSize.width*.05, HEIGHT);
    CGPoint position = ccp(winSize.width*.05, HEIGHT/3.0f*2.0f);
    for (int i = 0; i < health; i++){
        CCSprite *heart = [CCSprite spriteWithFile:@"heart.png"];
        heart.position = position;
        heart.scale = 1.25f;
        [lives addObject:heart];
        [self addChild:heart z:100];
        position = ccpAdd(position,ccp(20,0));
    }

}

-(void) setLives:(int) health {
    //if (abs([lives count]) == health)
    //    return;
   
    for (int i = 0; i < abs([lives count]); i++) {
        CCSprite *heart = [lives objectAtIndex:i];
        if (i >= health)
            heart.color = ccGRAY;
        else
            heart.color = ccWHITE;
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
@end

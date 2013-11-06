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
#define HEIGHT 20.0f

CCLabelTTF *scoreString;
CCLabelTTF *livesString;
CCLabelTTF *menuButton;
  NSMutableArray *hearts;

@interface HUDLayer (PrivateMethods)
// declare private methods here
@end


@implementation HUDLayer

-(id) init
{
	self = [super initWithColor:ccc4(255,255,255,5)];
	if (self)
	{

        CCLOG(@"HUDLAYER INIT");
        hearts = [[NSMutableArray alloc] init];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        [self setContentSize:CGSizeMake(winSize.width,HEIGHT*2)];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            scoreString = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Arial" fontSize:22.0f];
        } else {
            scoreString = [CCLabelTTF labelWithString:@"WOOOP!!" fontName:@"Arial" fontSize:16.0f];
        }
        //scoreString.position = ccp(winSize.width* 0.5, winSize.height - PADDING_TOP);
        scoreString.position = ccp(winSize.width* 0.5, HEIGHT);

        [self addChild:scoreString];
        
        
        menuButton = [CCLabelTTF labelWithString:@"menu" fontName:@"Arial" fontSize:16.0f];
        menuButton.position =  ccp(winSize.width* 0.9, HEIGHT);
        [self addChild:menuButton];
         
        /*
        livesString = [CCLabelTTF labelWithString:@"WOOOP" fontName:@"Arial" fontSize:16.0f];
        livesString.position = ccp(winSize.width*.15, winSize.height * .9);
        [self addChild:livesString];
         */
       // [self addChild:hearts];
        
        self.isTouchEnabled = YES;
    }
    
	return self;
}
/*
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
   
      CCLOG(@"DETECTED TOUCH on hudlayer!");
    
}
*/

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
       CCLOG(@"DETECTED TOUCH on hudlayer!");
     // CGPoint touchLocation = [touch locationInView:self.view];
    CGPoint touchStart = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // convert touch location to layer space
    touchStart = [self convertToNodeSpace:touchStart];
    [self handleMenuButton:touchStart];
    
}
 

-(void) update:(ccTime)delta
{
    KKInput* input = [KKInput sharedInput];
    
    if ([input isAnyTouchOnNode:menuButton touchPhase:KKTouchPhaseBegan])
    {
        CCLOG(@"DETECTED TOUCH ON MENUBUTTON!");
    }
}


-(void) handleMenuButton: (CGPoint)touch
{
    CGRect rect = menuButton.boundingBox;

    CCLOG(@"TOUCH RECEIVED ON MENU IS %@", NSStringFromCGPoint(touch));
    CCLOG(@"menu is %@", NSStringFromCGPoint(menuButton.boundingBoxCenter));
    //if (CGRectContainsPoint(rect, touch)){
    if (fabsf(menuButton.boundingBoxCenter.x - touch.x) <= rect.size.width/2 +10 &&
        fabsf(menuButton.boundingBoxCenter.y - touch.y) <= rect.size.height/2 +10 )
    {
       //    [[CCDirector sharedDirector] pushScene: (CCScene*)[[PauseLayer alloc] init]];
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameOverLayer alloc] init]];

    }
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
   // CGPoint position = ccp(winSize.width*.05, winSize.height - PADDING_TOP);
    CGPoint position = ccp(winSize.width*.05, HEIGHT);
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



@end

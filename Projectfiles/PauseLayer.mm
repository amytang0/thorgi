//
//  PauseLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/2/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "PauseLayer.h"

#import "GameLayer.h"
#import "HUDLayer.h"

#import "SimpleAudioEngine.h"

CCSprite *resume;
CCSprite *restart;
CCSprite *mutemusic;
CCSprite *mutesound;



#define FONT_SIZE 20.0f

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
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons.plist"];
       
        
               
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CGPoint pos = ccp(winSize.width* 0.1, winSize.height/2);
        
        // Makes texture tiled background
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"smalltexture3.png"];
        ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [texture setTexParameters:&params];
        CGRect r = [CCDirector sharedDirector].screenRectInPixels;
        CCSprite *bg = [[CCSprite alloc] initWithTexture:texture rect:r];
        bg.position = CGPointZero;
        [self addChild:bg z:-10];
        
        CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"play.png"];
        resume = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
        resume.position = pos;
        [resume setScale:1.5f];
        [self addChild:resume];
        pos = [self incrementPos:pos];
        
        buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"restart.png"];
        restart = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
        restart.position = pos;
         [restart setScale:1.5f];
        [self addChild:restart];
        pos = [self incrementPos:pos];
        
        buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"music.png"];
        mutemusic = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
        mutemusic.position = pos;
        [mutemusic setScale:1.5f];
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
            CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mutemusic.png"];
            //mutemusic = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
            [mutemusic setDisplayFrame:buttonFrame];
        }
        [self addChild:mutemusic];
        pos = [self incrementPos:pos];
    
        buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sound.png"];
        mutesound = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
        mutesound.position = pos;
         [mutesound setScale:1.5f];
        [self addChild:mutesound];
        pos = [self incrementPos:pos];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

-(CGPoint) incrementPos:(CGPoint)pos
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    return ccpAdd(pos, ccp(winSize.width*.25,0));
}


- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CCLOG(@"DETECTED TOUCH on pauseLayer!");
    // CGPoint touchLocation = [touch locationInView:self.view];
    CGPoint touchStart = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // convert touch location to layer space
    touchStart = [self convertToNodeSpace:touchStart];
    [self handleMenuButton:touchStart];
    
}

-(void) handleMenuButton: (CGPoint)touch
{
    // If in resume button
    if (fabsf(resume.boundingBoxCenter.x - touch.x) <= resume.boundingBox.size.width/2 +10 &&
        fabsf(resume.boundingBoxCenter.y - touch.y) <= resume.boundingBox.size.height/2 +10 )
    {
           [[CCDirector sharedDirector] popScene];
    }
    else if (fabsf(restart.boundingBoxCenter.x - touch.x) <= restart.boundingBox.size.width/2 +10 &&
        fabsf(restart.boundingBoxCenter.y - touch.y) <= restart.boundingBox.size.height/2 +10 )
    {
        [[CCDirector sharedDirector] popScene];
        HUDLayer *hud = [HUDLayer node];
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] initWithHUD:hud]];

    }
    else if (fabsf(mutemusic.boundingBoxCenter.x - touch.x) <= mutemusic.boundingBox.size.width/2 +10 &&
        fabsf(mutemusic.boundingBoxCenter.y - touch.y) <= mutemusic.boundingBox.size.height/2 +10 )
    {
       // [[CCDirector sharedDirector] popScene];
        CCLOG(@"mute music unimplemented");
        SimpleAudioEngine *audio = [SimpleAudioEngine sharedEngine];
        if ([audio isBackgroundMusicPlaying]) {
            [audio pauseBackgroundMusic];
            CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mutemusic.png"];
            //mutemusic = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
            [mutemusic setDisplayFrame:buttonFrame];
            
        } else {
            [audio resumeBackgroundMusic];
            CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"music.png"];
           // mutemusic = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
            [mutemusic setDisplayFrame:buttonFrame];
        }
        

    }
    else if (fabsf(mutesound.boundingBoxCenter.x - touch.x) <= mutesound.boundingBox.size.width/2 +10 &&
        fabsf(mutesound.boundingBoxCenter.y - touch.y) <= mutesound.boundingBox.size.height/2 +10 )
    {
       // [[CCDirector sharedDirector] popScene];
        CCLOG(@"mute sound unimplemented");
        SimpleAudioEngine *audio = [SimpleAudioEngine sharedEngine];
        if ([audio isBackgroundMusicPlaying]) {
            [audio pauseBackgroundMusic];
            CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mutesound.png"];
            //mutesound = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
            [mutesound setDisplayFrame:buttonFrame];
            
        } else {
            [audio resumeBackgroundMusic];
            CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sound.png"];
            //mutesound = [[CCSprite alloc] initWithSpriteFrame:buttonFrame];
             [mutesound setDisplayFrame:buttonFrame];
          
        }

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

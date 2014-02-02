//
//  GameOverLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/2/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "GameOverLayer.h"
#import "StartMenuLayer.h"
#import "LocalScoreLayer.h"

#import "GameState.h"
#import "GCHelper.h"


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
    
    LocalScoreLayer *scoreLayer = [LocalScoreLayer node];
    [scene addChild:scoreLayer z:1];
    
	// return the scene
	return scene;
}
-(id) initWithScore:(int)scorePoints
{
	self = [super init];
	if (self)
	{
        CGSize winSize = [CCDirector sharedDirector].winSize;

        // Makes texture tiled background
      /*
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"smalltexture3.png"];
        ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [texture setTexParameters:&params];
        CGRect r = [CCDirector sharedDirector].screenRectInPixels;
        CCSprite *bg = [[CCSprite alloc] initWithTexture:texture rect:r];
        [self addChild:bg z:-10];
       */
        
        // Makes sky background
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"sky.png"];
        ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [texture setTexParameters:&params];
        CGRect r = [CCDirector sharedDirector].screenRectInPixels;
        CCSprite *bg = [[CCSprite alloc] initWithTexture:texture rect:r];
        bg.position = ccp(50,50);
        [self addChild:bg z:-10];
              CCLOG(@"added background");
        /*
        // Put Score Board
        CCSpriteFrame *scoresFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"scores.png"];
        CCSprite  *scores = [[CCSprite alloc] initWithSpriteFrame:scoresFrame];
       // scores.position = ccp(winSize.width/2,winSize.height*2/3);
        scores.position = ccp(winSize.width/2, winSize.height/2);
        scores.scale = 2.0f;
        scores.rotation = 90;
        [self addChild: scores z:-1];
        CCLOG(@"added scoreboard");
         */
        /*
        CCLabelTTF  *scoresLabel =[CCLabelTTF labelWithString: [NSString stringWithFormat:@"Final Score: %d", scorePoints]
                                                  dimensions:CGSizeMake(winSize.width/2, 20)
                                                  hAlignment:kCCTextAlignmentLeft
                                                    fontName:@"Chalkduster"
                                                    fontSize:16];
        scoresLabel.position = ccp(winSize.width/2,winSize.height/2);
        [self addChild:scoresLabel z:-1];
         */
        /*
        LocalScoreLayer *scoreLayer = [[LocalScoreLayer alloc] init];
        scoreLayer.position = ccp(0,0);
        [self addChild:scoreLayer z:1];
        */
        CCMenuItemFont *gameOverItem = [[CCMenuItemFont alloc] initWithString:@"GAME OVER!" target:NULL selector:@selector(showHighScores)];
        gameOverItem.fontName = @"Chalkduster";
        gameOverItem.fontSize = 30;
        gameOverItem.color = ccBLACK;
        
        
        NSString *scoreString = [[NSString alloc] initWithFormat:@"Final Score: %d", scorePoints];
        CCMenuItemFont *scoreMenuItem = [[CCMenuItemFont alloc] initWithString:scoreString target:NULL selector:@selector(showHighScores)];
        scoreMenuItem.fontName = @"Chalkduster";
        scoreMenuItem.fontSize = 20;
        scoreMenuItem.color = ccBLACK;
       
        CCSprite *deadDog = [[CCSprite alloc] initWithFile:@"deadthorgi.png"];
        deadDog.position = ccp(winSize.width/2, 110);
        
        menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"deadthorgi.png" selectedImage:@"deadthorgi.png" target:self selector:@selector(showStartScreen:)];
        
        /*
        CCSpriteFrame *buttonFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"play.png"];
        menuPlayButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrame:buttonFrame]
                                                 selectedSprite:[CCSprite spriteWithSpriteFrame:buttonFrame]
                                                         target:self
                                                       selector:@selector(showStartScreen:)];
        menuPlayButton.scale = 1.5f;
         */
        
/*
        menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"button.png" selectedImage:@"button.png" target:self selector:@selector(showStartScreen:)];
  */              
        // Create a menu and add your menu items to it
        CCMenu * myMenu = [CCMenu menuWithItems: gameOverItem, scoreMenuItem, menuPlayButton, nil];
       
        // myMenu.position = ccp(winSize.width/2,winSize.height-60);
        // Arrange the menu items vertically
        [myMenu alignItemsVertically];
        
        // add the menu to your scene
        [self addChild:myMenu z:1];
              CCLOG(@"added menu");
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
        self.isTouchEnabled = YES;
        CCLOG(@"Saved score: %d",[GameState sharedInstance].scorePoints);
        
   
        
        GCHelper *helper = [GCHelper sharedInstance];
        if ([[GameState sharedInstance] addNewScore:scorePoints username:@"Bleh"]) {
            
            [GKNotificationBanner showBannerWithTitle:@"Got into top 10!" message:@"Yay! You're 20% cooler!" completionHandler:^{}];
        }
        
        if ([GameState sharedInstance].scorePoints < scorePoints) {
            [GameState sharedInstance].scorePoints = scorePoints;
            [[GameState sharedInstance] save];
            [helper reportScore:kLeaderboardScore score:scorePoints];
                CCLOG(@"SAVED SCORE");
            
             [GKNotificationBanner showBannerWithTitle:@"Beat your old high score!" message:@"Yay!" completionHandler:^{}];
            
            /*
            double pctComplete = ((double)
                                  [GameState sharedInstance].scorePoints /
                                  (int)maxTimesToFall) * 100.0;
            [[GCHelper sharedInstance]
             reportAchievement:kAchievementKillTen
             percentComplete:pctComplete];
            if ([GameState sharedInstance].timesFell >= maxTimesToFall) {
                achievementLabelText.string =
                @"Achievement Unlocked: Bad Dream!";
             */
        }
        if ([[GameState sharedInstance] getTotalCatsKilledThisGame] >= 10) {
            double pctComplete = ([[GameState sharedInstance] getTotalCatsKilledThisGame ] /10) * 100.0f;
            CCLOG(@"pctcomplete: %f", pctComplete);

            if ([helper reportAchievement:kAchievementKillTen percentComplete:pctComplete]) {
            [[GameState sharedInstance] save];
                CCSprite *achievement = [[CCSprite alloc] initWithFile:@"fire.png"];
                [self addChild:achievement z:1];
                // This should only show up once. TODO: fix
                //[GKNotificationBanner showBannerWithTitle:@"Achievement: Killed Ten Cats in One Game" message:@"Completed!" completionHandler:^{}];
            }           
           
            
            CCLOG(@"KILLED CATS %d", [[GameState sharedInstance] getTotalCatsKilledThisGame]);

        }
        if ([[GameState sharedInstance] getTotalCatsKilledThisGame] >= 0) {
            double pctComplete = ([[GameState sharedInstance] getTotalCatsKilledThisGame ] /100) * 100.0f;
            CCLOG(@"KILLED CATS %d", [[GameState sharedInstance] getTotalCatsKilledThisGame]);
            if ([helper reportAchievement:kAchievementKillHundred percentComplete:pctComplete]) {
                [[GameState sharedInstance] save];
                CCSprite *achievement = [[CCSprite alloc] initWithFile:@"fire.png"];
                [self addChild:achievement z:1];
                // This should only show up once. TODO: fix
                //[GKNotificationBanner showBannerWithTitle:@"Achievement: Killed 100 Cats in One Game" message:@"Completed!" completionHandler:^{}];
            }

        }
        
        // Send highscore.
       // [MGWU submitHighScore:scorePoints byPlayer:[GameState sharedInstance].username forLeaderboard:@"defaultLeaderboard"];
       // CCLOG(@"User: %@ score: %d", [GameState sharedInstance].username, scorePoints);
        
        // Touch hack.
        KKInput* input = [KKInput sharedInput];
        
        input.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* tapGestureRecognizer;
        tapGestureRecognizer = input.tapGestureRecognizer;
        tapGestureRecognizer.cancelsTouchesInView = NO;

        // Logging
        NSNumber* levelnumber = [NSNumber numberWithInt:1];
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithInt:scorePoints], @"score",
                [NSNumber numberWithInt:[[GameState sharedInstance] basicCatsKilledThisGame]], @"basic_cats_killed",
                [NSNumber numberWithInt:[[GameState sharedInstance] dashCatsKilledThisGame]], @"dash_cats_killed",
                [NSNumber numberWithInt:[[GameState sharedInstance] wizardCatsKilledThisGame]], @"wizard_cats_killed",
                [NSNumber numberWithInt:[[GameState sharedInstance] nyanCatsKilledThisGame]], @"nyan_cats_killed",
                [NSNumber numberWithInt:[[GameState sharedInstance] lokiCatsKilledThisGame]], @"loki_cats_killed",
                nil];
        [MGWU logEvent:@"dog_died" withParams:parameters];
        
        
        
	}
	return self;
}



- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchStart = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // convert touch location to layer space
    touchStart = [self convertToNodeSpace:touchStart];

    CCLOG(@"DETECTED TOUCH on gameOverlayer!");
    if (fabsf(menuPlayButton.boundingBoxCenter.x - touchStart.x) <= menuPlayButton.boundingBox.size.width/2 +10 &&
        fabsf(menuPlayButton.boundingBoxCenter.y - touchStart.y) <= menuPlayButton.boundingBox.size.height/2 +10 )
    {
        [self showStartScreen:menuPlayButton];
    }
    
}

-(void) showHighScores
{
     NSLog(@"Show high scores");
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
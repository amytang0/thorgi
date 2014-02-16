//
//  StartMenuLayer.m
//  PeevedPenguins
//
//  Created by Amy Tang on 10/12/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "StartMenuLayer.h"
#import "GameLayer.h"
#import "StoreLayer.h"

#import "GameState.h"

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

        [self showUsernameInputBox:self];
        
        CGRect appframe= [[UIScreen mainScreen] applicationFrame];
        
        glClearColor(.001f, .581f, .823f, 1.0f);
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"thorgitext.png"];
        CGSize size = sprite.textureRect.size;
        int padding = 30;
        sprite.scale = (1.0f*appframe.size.height-padding)/(1.0f*MAX(size.width, size.height));
        sprite.position = ccp(padding/2, appframe.size.width-120);
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        sprite = [CCSprite spriteWithFile:@"dogofthundertext.png"];
        sprite.scale = (1.0f*appframe.size.height-padding)/(1.0f*MAX(size.width, size.height));
        sprite.position = ccp(sprite.scale*padding/2, appframe.size.width -120 - size.height + 10);
        sprite.anchorPoint = CGPointZero;
        //sprite.color = ccWHITE;
        [self addChild:sprite z:-1];
        
        CCMenuItemImage *menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"thorgipose.png" selectedImage:@"thorgipose.png"  target:self selector:@selector(playGame:)];
        menuPlayButton.scale = 1.75f;
       // menuPlayButton.position = ccp(appframe.size.height/2, appframe.size.width*2/3);
        menuPlayButton.tag = 1;
        
        
        CCMenuItemImage *menuStoreButton = [CCMenuItemImage itemWithNormalImage:@"thorgitext.png" selectedImage:@"thorgitext.png"  target:self selector:@selector(showStore:)];
        
        CCMenuItemImage *menuMoreGamesButton = [CCMenuItemImage itemWithNormalImage:@"deadthorgi.png" selectedImage:@"deadthorgi.png"  target:self selector:@selector(moreGames:)];
        
        
        
        // Create a menu and add your menu items to it
        CCMenu *myMenu = [CCMenu menuWithItems:menuPlayButton, menuStoreButton, menuMoreGamesButton, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsHorizontally];
        myMenu.position = ccp(appframe.size.height/2, 105);
        
        // add the menu to your scene
        [self addChild:myMenu];
        
        self.isTouchEnabled = YES;
        
        [self initGameState];
        
       		
        // uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

// This shows the alert asking for username input.
- (IBAction)showUsernameInputBox:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"username_set"]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New User" message:@"Please enter your username" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Confirm",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
}

// This should handle what happens to the username
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"username_set"]) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Confirm"])
        {
            UITextField *username = [alertView textFieldAtIndex:0];
            [defaults setBool:YES forKey:@"username_set"];
            [defaults setObject:username.text forKey:@"username"];
            [defaults synchronize];
            NSLog(@"Username: %@", username.text);
        }
    }
    
}

// Prevents usernames longer than 10 characters.
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] <= 10 || [inputText length] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void) initGameState
{
   // Retrieving top scores
       // CCLOG(@"retrieving top scores");
        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
        if (leaderboardRequest != nil)
        {
            leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
            leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
            //leaderboardRequest.category = @"com.amytang.thorgi.leaderboard.scores";
            leaderboardRequest.category = @"1";
           // CCLOG(@"groupIdent %@",leaderboardRequest.debugDescription);
            leaderboardRequest.range = NSMakeRange(1,10);
            [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
                if (error != nil)
                {
                    // Handle the error.]
                    CCLOG(@"Error occurred while retrieving leaderboard. %@",error);
                }
                if (scores != nil)
                {
                   // CCLOG(@"Scores not null retrieved!, %@", scores.mutableCopy);
                    [GameState sharedInstance].topTenScores = scores.mutableCopy;
                    [[GameState sharedInstance] save];
                  //  CCLOG(@"Scores retrieved1!, %@", [GameState sharedInstance].topTenScores  ) ;
                 //   CCLOG(@"Scores retrieved!, %@", [[GameState sharedInstance]getTopTenScores ] );
                } else {
                    CCLOG(@"scores is nil!");
                    
                }
            }];
        }
    
}


-(void) playGame:(CCMenuItem *)sender 
{
    HUDLayer *hud = [HUDLayer node];
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] initWithHUD:hud]];
}

-(void) showStore:(CCMenuItem *)sender
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[StoreLayer alloc] init]];
}

-(void) moreGames:(CCMenuItem *)sender
{
   [MGWU displayCrossPromo];
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
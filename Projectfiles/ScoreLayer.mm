//
//  ScoreLayer.m
//  Thorgi
//
//  Created by Amy Tang on 11/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ScoreLayer.h"
#import "GCDatabase.h"
#import "GameState.h"

@interface ScoreLayer (PrivateMethods)
// declare private methods here
@end

@implementation ScoreLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	ScoreLayer *layer = [[ScoreLayer alloc] init];
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
        CCLOG(@"Scorelayer init");
        CCLOG(@"Bleh %@", [GameState sharedInstance]);
        CCLOG(@"TOPTEN SCORE %@",[[GameState sharedInstance] getTopTenScores ] );
        NSMutableArray *scoresArray = [GameState sharedInstance].topTenScores;
        for (GKScore *score : scoresArray) {
            //GKPlayer *player = [[GKPlayer alloc] init];
            
            NSString *string = [NSString stringWithFormat:@"%d | %@ %@", score.rank, score.playerID, score.formattedValue];
            CCLOG(@"string %@",string);
            CCLOG(@"given %@", score.formattedValue);
        CCLabelTTF  *scoreTextLabel =[CCLabelTTF labelWithString:[NSString
                                                                      stringWithFormat:@"%@", string]
                                                            fontName:@"Chalkduster"
                                                            fontSize:20];
            scoreTextLabel.position = ccp(250,50);
            scoreTextLabel.color = ccBLACK;
            [self addChild:scoreTextLabel];
        }
	}
	return self;
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

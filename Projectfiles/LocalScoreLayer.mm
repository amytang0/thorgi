//
//  LocalScoreLayer.m
//  Thorgi
//
//  Partial view of the scores board.
//  Created by Amy Tang on 11/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LocalScoreLayer.h"
#import "LocalScore.h"
#import "GameState.h"


@interface LocalScoreLayer (PrivateMethods)
// declare private methods here
@end

@implementation LocalScoreLayer

//Remove later
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	LocalScoreLayer *layer = [[LocalScoreLayer alloc] init];
	// add layer as a child to scene
	[scene addChild: layer z:0];
	// return the scene
	return scene;
}

-(id) init
{
    CCLOG(@"init localscore?");
	self = [super init];
	if (self)
	{
        [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
        
        
        
        // Set content size to be partial width of screen
        CGSize winSize = [CCDirector sharedDirector].winSize;
        [self setContentSize:CGSizeMake(winSize.width/2.0f,winSize.height)];

        
        // Set starting point of text
        pos = ccp(winSize.width*.37,winSize.height*.85);
        
        // First put table label on top
        [self writeHeaderRow];
        
        NSMutableArray *scoresArray = [GameState sharedInstance].topTenScoresLocal;
        for (int i = 0; i < (int)[scoresArray count]; i++) {
            LocalScore *ls = scoresArray[i];
            [self writeScoreRow:ls rank:i+1];
        }
        
        // Put Score Board
          CCSpriteFrame *scoresFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"scores.png"];
         CCSprite  *scores = [[CCSprite alloc] initWithSpriteFrame:scoresFrame];
         scores.position = ccp(winSize.width/3,winSize.height/2);
         scores.scale = 2.7f;
         [self addChild: scores z:-1];
        self.isTouchEnabled = FALSE;

	}
	return self;
}

//If there is no connection to the internet, scoreArray will be nil.
- (void)receivedScores:(NSDictionary*)scores {
    //Do stuff with scores in here! Display them!
    NSEnumerator *enumerator = [scores keyEnumerator];
    id key = [enumerator nextObject];
    while ((key = [enumerator nextObject])) {
        NSDictionary *player = [scores objectForKey:key];
        
        NSString *name = [player objectForKey:@"name"];
        NSNumber *s = [player objectForKey:@"score"];
        int score = [s intValue];
        //Do something with name and score
        CCLOG(@"name: %@, %d",name,score);
    }
/*
    for (int i = 1; i < [scoreArray count]; i++)
    {
        NSDictionary *player = [scoreArray objectAtIndex:i];
        NSString *name = [player objectForKey:@"name"];
        NSNumber *s = [player objectForKey:@"score"];
        int score = [s intValue];
        //Do something with name and score
        CCLOG(@"name: %@, %d",name,score);
    }
 */
}


-(void) moveToNewLine
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    pos = CGPointMake(winSize.width*.37,pos.y-23);
}

-(void) moveRightPos1
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    pos = ccpAdd(pos, ccp(winSize.width*.08, 0));
}

-(void) moveRightPos2
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    pos = ccpAdd(pos, ccp(winSize.width*.2, 0));
}


-(void) writeHeaderRow
{
    CGSize winSize = [CCDirector sharedDirector].winSize;

    CCLabelTTF  *titleLabel =[CCLabelTTF labelWithString:@"#"
                                              dimensions:CGSizeMake(winSize.width/2, 20)
                                              hAlignment:kCCTextAlignmentLeft
                                                fontName:@"Chalkduster"
                                                fontSize:20];
    titleLabel.color = ccBLACK;
    titleLabel.position = pos;
    [self addChild:titleLabel];
    [self moveRightPos1];
    
    titleLabel = titleLabel =[CCLabelTTF labelWithString:@"Name"
                                              dimensions:CGSizeMake(winSize.width/2, 20)
                                              hAlignment:kCCTextAlignmentLeft
                                                fontName:@"Chalkduster"
                                                fontSize:20];
    titleLabel.color = ccBLACK;
    titleLabel.position = pos;
    [self addChild:titleLabel];
    [self moveRightPos2];
    
    titleLabel = titleLabel =[CCLabelTTF labelWithString:@"Score"
                                              dimensions:CGSizeMake(winSize.width/2, 20)
                                              hAlignment:kCCTextAlignmentLeft
                                                fontName:@"Chalkduster"
                                                fontSize:20];
    titleLabel.color = ccBLACK;
    titleLabel.position = pos;
    [self addChild:titleLabel];
    [self moveToNewLine];

}

-(void) writeScoreRow:(LocalScore*)ls rank:(int)rank
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
       CCLabelTTF  *titleLabel =[CCLabelTTF labelWithString: [NSString stringWithFormat:@"%d", rank]
                                              dimensions:CGSizeMake(winSize.width/2, 20)
                                              hAlignment:kCCTextAlignmentLeft
                                                fontName:@"Chalkduster"
                                                fontSize:16];
   // titleLabel.color = ccBLACK;
    titleLabel.position = pos;
    [self addChild:titleLabel];
    [self moveRightPos1];
    
    titleLabel = titleLabel =[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", ls.username]
                                              dimensions:CGSizeMake(winSize.width/2, 20)
                                              hAlignment:kCCTextAlignmentLeft
                                                fontName:@"Chalkduster"
                                                fontSize:16];
   // titleLabel.color = ccBLACK;
    titleLabel.position = pos;
    [self addChild:titleLabel];
    [self moveRightPos2];
    
    titleLabel = titleLabel =[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", ls.score]
                                              dimensions:CGSizeMake(winSize.width/2, 20)
                                              hAlignment:kCCTextAlignmentLeft
                                                fontName:@"Chalkduster"
                                                fontSize:16];
   // titleLabel.color = ccBLACK;
    titleLabel.position = pos;
    [self addChild:titleLabel];
    [self moveToNewLine];

    
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

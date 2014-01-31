//
//  GameState.mm
//  Thorgi
//  Holds GameState values
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"
#import "LocalScore.h"

@implementation GameState
@synthesize scorePoints;

@synthesize basicCatsKilledTotal;
@synthesize dashCatsKilledTotal;
@synthesize wizardCatsKilledTotal;
@synthesize nyanCatsKilledTotal;
@synthesize lokiCatsKilledTotal;

@synthesize basicCatsKilledThisGame;
@synthesize dashCatsKilledThisGame;
@synthesize wizardCatsKilledThisGame;
@synthesize nyanCatsKilledThisGame;
@synthesize lokiCatsKilledThisGame;

@synthesize muteMusic;
@synthesize muteSound;

@synthesize topTenScores;
@synthesize topTenScoresLocal;

static GameState *sharedInstance = nil;
+(GameState*)sharedInstance {
    @synchronized([GameState class])
    {
        if(!sharedInstance) {
            //sharedInstance = [loadData(@"GameState")];
            sharedInstance = loadData(@"GameState");
            if (!sharedInstance) {
                sharedInstance = [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil; }
+(id) alloc {
    @synchronized ([GameState class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a \
                 second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil; }
- (void)save {
    saveData(self, @"GameState");
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:scorePoints forKey:@"scorePoints"];
    [encoder encodeInt:basicCatsKilledTotal forKey:@"basicCatsKilledTotal"];
    [encoder encodeInt:dashCatsKilledTotal forKey:@"dashCatsKilledTotal"];
    [encoder encodeInt:wizardCatsKilledTotal forKey:@"wizardCatsKilledTotal"];
    [encoder encodeInt:nyanCatsKilledTotal forKey:@"nyanCatsKilledTotal"];
    
    [encoder encodeInt:basicCatsKilledThisGame forKey:@"basicCatsKilledThisGame"];
    [encoder encodeInt:dashCatsKilledThisGame forKey:@"dashCatsKilledThisGame"];
    [encoder encodeInt:wizardCatsKilledThisGame forKey:@"wizardCatsKilledThisGame"];
    [encoder encodeInt:nyanCatsKilledThisGame forKey:@"nyanCatsKilledThisGame"];
    
    [encoder encodeBool:muteMusic forKey:@"muteMusic"];
    [encoder encodeBool:muteSound forKey:@"muteSound"];
    
    [encoder encodeObject:topTenScores forKey:@"topTenScores"];
    [encoder encodeObject:topTenScoresLocal forKey:@"topTenScoresLocal"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        scorePoints = [decoder decodeIntForKey:@"scorePoints"];
        basicCatsKilledTotal = [decoder decodeIntForKey:@"basicCatsKilledTotal"];
        dashCatsKilledTotal = [decoder decodeIntForKey:@"dashCatsKilledTotal"];
        wizardCatsKilledTotal = [decoder decodeIntForKey:@"wizardCatsKilledTotal"];
        nyanCatsKilledTotal = [decoder decodeIntForKey:@"nyanCatsKilledTotal"];
        basicCatsKilledThisGame = [decoder decodeIntForKey:@"basicCatsKilledThisGame"];
        dashCatsKilledThisGame = [decoder decodeIntForKey:@"dashCatsKilledThisGame"];
        wizardCatsKilledThisGame = [decoder decodeIntForKey:@"wizardCatsKilledThisGame"];
        nyanCatsKilledThisGame = [decoder decodeIntForKey:@"nyanCatsKilledThisGame"];
        
        muteMusic = [decoder decodeBoolForKey:@"muteMusic"];
        muteSound = [decoder decodeBoolForKey:@"muteSound"];
        topTenScores = [[decoder decodeObjectForKey:@"topTenScores"] mutableCopy];
        topTenScoresLocal = [[decoder decodeObjectForKey:@"topTenScoresLocal"] mutableCopy];
    }
    return self;
}
-(NSMutableArray *) getTopTenScores {
    return topTenScores;
}

-(void) newGame {
    basicCatsKilledThisGame = 0;
    dashCatsKilledThisGame = 0;
    wizardCatsKilledThisGame = 0;
    
}
-(int)getTotalCatsKilledThisGame {
    return basicCatsKilledThisGame +
           dashCatsKilledThisGame +
           wizardCatsKilledThisGame +
           nyanCatsKilledThisGame +
           lokiCatsKilledThisGame ;
}

-(int)getTotalCatsKilledTotal {
    return basicCatsKilledTotal +
           dashCatsKilledTotal +
           wizardCatsKilledTotal +
           nyanCatsKilledTotal +
           lokiCatsKilledTotal ;
}

// Returns true if score was added to top ten.
-(Boolean) addNewScoreGameCenter:(int) score {
    for (int i = 0; i < (int)[topTenScores count]; i++) {
        GKScore *s = topTenScores[i];
        GKScore *newScore = [[GKScore alloc] init];
        newScore.value = score;
        if (score > s.value) {
            [topTenScores insertObject:newScore atIndex:i];
            [topTenScores removeLastObject];
            return true;
        }
    }
    return false;
}

-(Boolean) addNewScore:(int) score username:(NSString *)username {
     LocalScore *ls = [[LocalScore alloc] initWithScoreAndUsername:score username:username];
    if (!topTenScoresLocal) {
     topTenScoresLocal = [[NSMutableArray alloc] init];
        
        [topTenScoresLocal addObject:ls];
        CCLOG(@"toptenscores was set to new nsmutablearray");
        [self save];
        return true;
    }

    int numberOfScores = (int)[topTenScoresLocal count];
    for (int i = 0; i < (int)[topTenScoresLocal count]; i++) {
        
        LocalScore *oldScore = topTenScoresLocal[i];
        if (score > oldScore.score) {
            [topTenScoresLocal insertObject:ls atIndex:i];
            if (numberOfScores >= 10) {
              [topTenScoresLocal removeLastObject];
            }
            [self save];
            return true;
        }
    }
    if (numberOfScores < 10){
        [topTenScoresLocal addObject:ls];
        [self save];
        return true;
    }
    return false;
}


@end
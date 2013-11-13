//
//  GameState.m
//  Thorgi
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"
@implementation GameState
@synthesize scorePoints;

@synthesize basicCatsKilledTotal;
@synthesize dashCatsKilledTotal;
@synthesize wizardCatsKilledTotal;
@synthesize nyanCatsKilledTotal;

@synthesize basicCatsKilledThisGame;
@synthesize dashCatsKilledThisGame;
@synthesize wizardCatsKilledThisGame;
@synthesize nyanCatsKilledThisGame;

static GameState *sharedInstance = nil;
+(GameState*)sharedInstance {
    @synchronized([GameState class])
    {
        if(!sharedInstance) {
            //sharedInstance = [loadData(@"GameState")];
            sharedInstance = loadData(@"GameState");
            if (!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil; }
+(id)alloc {
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
    [encoder encodeInt:scorePoints forKey:@"basicCatsKilledTotal"];
    [encoder encodeInt:scorePoints forKey:@"dashCatsKilledTotal"];
    [encoder encodeInt:scorePoints forKey:@"wizardCatsKilledTotal"];
    [encoder encodeInt:scorePoints forKey:@"basicCatsKilledThisGame"];
    [encoder encodeInt:scorePoints forKey:@"dashCatsKilledThisGame"];
    [encoder encodeInt:scorePoints forKey:@"wizardCatsKilledThisGame"];
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
    }
    return self;
}

-(void) newGame {
    basicCatsKilledThisGame = 0;
    dashCatsKilledThisGame = 0;
    wizardCatsKilledThisGame = 0;
    
}
-(int)getTotalCatsKilledThisGame {
    return basicCatsKilledThisGame +
           dashCatsKilledThisGame +
           wizardCatsKilledThisGame;
}

-(int)getTotalCatsKilledTotal {
    return basicCatsKilledTotal +
    dashCatsKilledTotal +
    wizardCatsKilledTotal;
}
@end
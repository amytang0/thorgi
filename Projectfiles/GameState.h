//
//  GameState.h
//  Thorgi
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GameState : NSObject <NSCoding> {
    
    int timesFell;
}
+ (GameState *) sharedInstance;
- (void)save;
-(int)getTotalCatsKilledThisGame;
-(int)getTotalCatsKilledTotal;
-(void) newGame;
-(Boolean) addNewScore:(int) score username:(NSString *)username;
-(NSMutableArray *) getTopTenScores ;

@property (assign) NSString* username;

@property (assign) int scorePoints;
@property (assign) int basicCatsKilledTotal;
@property (assign) int dashCatsKilledTotal;
@property (assign) int wizardCatsKilledTotal;
@property (assign) int nyanCatsKilledTotal;
@property (assign) int lokiCatsKilledTotal;

@property (assign) int basicCatsKilledThisGame;
@property (assign) int dashCatsKilledThisGame;
@property (assign) int wizardCatsKilledThisGame;
@property (assign) int nyanCatsKilledThisGame;
@property (assign) int lokiCatsKilledThisGame;

@property (assign) Boolean muteMusic;
@property (assign) Boolean muteSound;

@property (nonatomic, retain) NSMutableArray *topTenScores;
@property (nonatomic, retain) NSMutableArray *topTenScoresLocal;


@end

//
//  GameState.h
//  Thorgi
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GameState : NSObject <NSCoding> {
    BOOL completedLevel1;
    BOOL completedLevel2;
    BOOL completedLevel3;
    BOOL completedLevel4;
    BOOL completedLevel5;
    int timesFell;
}
+ (GameState *) sharedInstance;
- (void)save;
-(int)getTotalCatsKilledThisGame;
-(int)getTotalCatsKilledTotal;
-(void) newGame;
@property (assign) int scorePoints;
@property (assign) int basicCatsKilledTotal;
@property (assign) int dashCatsKilledTotal;
@property (assign) int wizardCatsKilledTotal;
@property (assign) int nyanCatsKilledTotal;

@property (assign) int basicCatsKilledThisGame;
@property (assign) int dashCatsKilledThisGame;
@property (assign) int wizardCatsKilledThisGame;
@property (assign) int nyanCatsKilledThisGame;
@end

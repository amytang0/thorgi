//
//  GCHelper.h
//  Thorgi
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementKillTen @"com.amytang.thorgi.achievement.kill_ten_enemies"
#define kLeaderboardScore @"com.amytang.thorgi.leaderboard.scores"

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
}
@property (retain) NSMutableArray *scoresToReport;
@property (retain) NSMutableArray *achievementsToReport;

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)authenticationChanged;

- (void)save;
- (id)initWithScoresToReport:(NSMutableArray *)scoresToReport
        achievementsToReport:(NSMutableArray *)achievementsToReport;
- (void)reportAchievement:(NSString *)identifier
          percentComplete:(double)percentComplete;
- (void)reportScore:(NSString *)identifier score:(int)score;
@end
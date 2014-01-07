//
//  GCHelper.h
//  Thorgi
//
//  This was mostly copied from Ray Wenderlich's book.
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementKillTen @"com.amytang.thorgi.achievement.kill_ten_enemies"
#define kAchievementKillHundred @"com.amytang.thorgi.achievement.kill_hundred_enemies"
//#define kAchievementKillTen @"com.amytang.thorgi.achievement.kill_ten_enemies"
#define kLeaderboardScore @"1"

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
- (Boolean)reportAchievement:(NSString *)identifier
          percentComplete:(double)percentComplete;
- (void)reportScore:(NSString *)identifier score:(int)score;
@end
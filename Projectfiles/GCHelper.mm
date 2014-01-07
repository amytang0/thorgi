//
//  GCHelper.m
//  Thorgi
//
//  Created by Amy Tang on 11/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GCHelper.h"
#import "GCDatabase.h"

@interface GCHelper (PrivateMethods)
// declare private methods here
@end

@implementation GCHelper
@synthesize gameCenterAvailable;
@synthesize scoresToReport;
@synthesize achievementsToReport;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    @synchronized([GCHelper class])
    {
        if (!sharedHelper) {
            sharedHelper = loadData(@"GameCenterData");
            if (!sharedHelper) {
                CCLOG(@"no pre-existing helper");
                sharedHelper = [[self alloc]
                initWithScoresToReport:[NSMutableArray array]
                achievementsToReport:[NSMutableArray array]];
            } }
        return sharedHelper;
    }
    return nil; }

- (void)save {
    saveData(self, @"GameCenterData");
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    return (gcClass && osVersionSupported);
}

-  (id)initWithScoresToReport:(NSMutableArray *)theScoresToReport achievementsToReport:(NSMutableArray *)theAchievementsToReport {
    if ((self = [super init])) {
        self.scoresToReport = theScoresToReport;
        self.achievementsToReport = theAchievementsToReport;
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
       return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        [self resendData];
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
}

- (void)sendScore:(GKScore *)score {
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
           {
               if (error == NULL) {
                   NSLog(@"Successfully sent score!");
                   [scoresToReport removeObject:score];
               } else {
                   NSLog(@"Score failed to send... will try again later.Reason: %@", error.localizedDescription);
               }
           });
    }];
}

- (void)sendAchievement:(GKAchievement *)achievement {
    CCLOG(@"Sending achievement");
    [achievement reportAchievementWithCompletionHandler: ^(NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (error == NULL) {
                NSLog(@"Successfully sent achievement!");
                [achievementsToReport removeObject:achievement];
            } else {
                NSLog(@"Achievement failed to send... will try again \
                      later. Reason: %@", error.localizedDescription);
            }
        });
    }];
}

- (void)resendData {
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
    for (GKScore *score in scoresToReport) {
        [self sendScore:score];
    }
}

#pragma mark User functions

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void)reportScore:(NSString *)identifier score:(int)rawScore {
    GKScore *score = [[GKScore alloc]
                       initWithCategory:identifier];
    score.value = rawScore;
    [scoresToReport addObject:score];
    [self save];
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendScore:score];
    CCLOG(@"Finished reportScore");
}

- (Boolean)reportAchievement:(NSString *)identifier
          percentComplete:(double)percentComplete {
    __block Boolean sentAchievement=FALSE;
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error) NSLog(@"Error retrieving old achievements");
        if (achievements != nil) {
            CCLOG(@"achievements: %@", achievements);
            for (GKAchievement *ach in achievements) {
                CCLOG(@"ach: %@",ach);
                if([ach.identifier isEqualToString:identifier]) { //already submitted
                    NSLog(@"Already submitted %@", identifier);
                    sentAchievement = FALSE;
                    return;
                }
            }
        }
    
        GKAchievement* achievement = [[GKAchievement alloc]
                                      initWithIdentifier:identifier];
        achievement.percentComplete = percentComplete;
        [achievementsToReport addObject:achievement];
        [self save];
        if (!gameCenterAvailable || !userAuthenticated) {
            CCLOG(@"Game center not available or user not auth");
            sentAchievement = FALSE;
            return;
        }
        achievement.showsCompletionBanner = YES;
        //[self sendAchievement:achievement];
            sentAchievement = TRUE;
        return;
    }];
    return sentAchievement;
}



- (void) resetAchievements
{
    //TODO: MAKE ACHIEVEMNTSDICTIONARY!
    // Clear all locally saved achievement objects.
    //achievementsDictionary = [[NSMutableDictionary alloc] init];
    // Clear all progress saved on Game Center.
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil){
             // handle the error.
             CCLOG(@"bleh");
         }
     }];
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:scoresToReport forKey:@"ScoresToReport"];
    [encoder encodeObject:achievementsToReport
                   forKey:@"AchievementsToReport"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    NSMutableArray * theScoresToReport = [decoder decodeObjectForKey:@"ScoresToReport"];
    NSMutableArray * theAchievementsToReport = [decoder decodeObjectForKey:@"AchievementsToReport"];
    return [self initWithScoresToReport:theScoresToReport
                   achievementsToReport:theAchievementsToReport];
}


@end

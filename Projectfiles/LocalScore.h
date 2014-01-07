//
//  LocalScore.h
//  Thorgi
//
//  Created by Amy Tang on 11/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"

@interface LocalScore : NSObject
{
@protected
@private
}
@property int score;
@property NSString *username;
-(id) initWithScoreAndUsername:(int) score username:(NSString *)username;
@end

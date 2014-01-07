//
//  HUDLayer.h
//  Thorgi
//
//  Created by Amy Tang on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "kobold2d.h"

@interface HUDLayer : CCLayerColor
{
@protected
@private
    int score;
    CCLabelTTF *scoreString;
    CCSprite *pauseButton;
    NSMutableArray *lives;
}
-(void) setScoreString:(NSString *)string;
-(void) setScore:(int) score;
-(void) setLives:(int) health;

@end

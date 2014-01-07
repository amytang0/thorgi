//
//  PauseLayer.h
//  Thorgi
//
//  Created by Amy Tang on 11/2/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "kobold2d.h"

@interface PauseLayer : CCLayer
{
@protected
@private
    CCSprite *resume;
    CCSprite *restart;
    CCSprite *quit;
    CCSprite *mutemusic;
    CCSprite *mutesound;
    int score;
}
+(id) scene;
-(id) initWithScore:(int)scorePoints;

@end

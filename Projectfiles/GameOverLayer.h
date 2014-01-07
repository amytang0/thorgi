//
//  GameOverLayer.h
//  Thorgi
//
//  Created by Amy Tang on 11/2/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "kobold2d.h"

@interface GameOverLayer : CCLayer
{
@protected
@private
    CCMenuItemImage *menuPlayButton;
}
+(id) scene;
-(id) initWithScore:(int)scorePoints;
-(void) showStartScreen:(CCMenuItem *)sender;
@end


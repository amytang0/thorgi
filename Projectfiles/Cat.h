//
//  Cat.h
//  Thorgi
//
//  Created by Amy Tang on 10/14/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "kobold2d.h"

@interface Cat : CCSprite
{
@protected
@private
}

@property int health;
@property int points, speed;
@property NSString *direction;
@property CCAction *moveAction;
-(id) initWithCatImage;
-(id) initWithAnimatedCat;

@end

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
@property int points;
-(id) initWithCatImage;
@end

//
//  Dog.h
//  My-User-Input-Project
//
//  Created by Amy Tang on 11/1/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "kobold2d.h"

@interface Dog : CCSprite
{
@protected
@private
}
@property int health;
@property NSString *status;
@property NSString *dogDirection;
@property CCAction *dogMoveAction;
-(id) initWithDogImage;
-(void) setMoveDirection: (NSString*)d;
-(void) stopAction;
@end

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
@property int points, numFrames;
@property float speed;
@property NSString *direction, *name;
@property CCAction *moveAction;
@property b2Vec2 velocity;
-(id) initWithAnimatedCat;
-(void) setMoveDirection: (NSString*)d;

@end

@interface DashCat : Cat
{
    
}
@end

@interface NyanCat : Cat
{
    
}
-(id) initWithAnimatedNyanCat;
@end


@interface WizardCat : Cat
{

}
@property int countdown;
-(void) resetCountDown;
@end

@interface Lokitty : WizardCat
{
    
}
@property float teleportTime;
@end





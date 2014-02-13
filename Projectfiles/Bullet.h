//
//  Bullet.h
//  Thorgi
//
//  Created by Amy Tang on 11/1/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "kobold2d.h"

@interface Bullet : CCSprite
{
@protected
@private
}
@property int damage;
-(id) initWithBulletImage;
@end

@interface WizardBullet : Bullet
{
    
}
@end

@interface DerpBullet : Bullet
{
    
}
@end

@interface MineBullet : Bullet
{
    
}
@end
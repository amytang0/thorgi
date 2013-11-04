/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"

#import "Box2D.h"
#import "ContactListener.h"
#import "Dog.h"


@interface GameLayer : CCLayer
{
    b2World* world;
    ContactListener *contactListener;
    b2Body *screenBorderBody;
    
    Dog *dogSprite;
	b2Body* dogBody;
	CCParticleSystem* particleFX;
    
    b2Body *bulletBody;
    
    
    NSMutableArray *bullets;
    NSMutableArray *bulletsLocations;
    
    CCMenu *menu;
    
}
+(id) scene;

extern const float PTM_RATIO;

@end

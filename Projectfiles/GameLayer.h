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
#import "HUDLayer.h"


enum {
    SpriteStateNormal,
    SpriteStateHit,
    SpriteStateInvincible,
    SpriteStateRemove
};
typedef NSInteger SpriteState;

@interface GameLayer : CCLayer
{
    HUDLayer * hud;
    
    b2World* world;
    ContactListener *contactListener;
    b2Body *screenBorderBody;
    
    Dog *dogSprite;
	b2Body* dogBody;
	CCParticleSystem* particleFX;
    
    b2Body *bulletBody;
    
    
    //NSMutableArray *bullets;
    //NSMutableArray *bulletsLocations;
    
    CCMenu *menu;
    CCMenuItem *scoreItem;
    int score;
    
}
+(id) scene;
- (id)initWithHUD:(HUDLayer *)hudLayer;

extern const float PTM_RATIO;

@end



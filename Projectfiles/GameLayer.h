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

typedef enum 
{
	kAccelerometerValuesRaw,
	kAccelerometerValuesSmoothed,
	kAccelerometerValuesInstantaneous,
	kGyroscopeRotationRate,
	kDeviceMotion,
	
	kInputTypes_End,
} InputTypes;

@interface GameLayer : CCLayer
{
    b2World* world;
    ContactListener *contactListener;
    b2Body *screenBorderBody;
    
	Dog* dog;
	CCParticleSystem* particleFX;
	InputTypes inputType;
    
    b2Body *bulletBody;
    
    NSMutableArray *bullets;
    NSMutableArray *bulletsLocations;
    NSMutableArray *tauntingFrames;
        CCAction *taunt;
}
- (void)createBullets;

@end

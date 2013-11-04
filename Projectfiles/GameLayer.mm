/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */
#include <stdlib.h>

#import "GameLayer.h"

#import "cocos2d.h"

#import "Bullet.h"
#import "Cat.h"
#import "Dog.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"


#define MAX_SPEED 15.0
#define BOARD_LENGTH 500
#define BULLET_SPEED 15.0
const float PTM_RATIO = 32.0f;
//#define PTM_RATIO 32.0f

NSMutableArray *enemies;
CCSprite *enemy;
CGRect firstrect;
CGRect secondrect;

@interface GameLayer (PrivateMethods)
-(void) changeInputType:(ccTime)delta;
-(void) postUpdateInputTests:(ccTime)delta;
-(void) createBullets:(CGPoint)location;
-(void) populateWithCats;
-(void) initWorld;
-(void) initDog;
-(CGPoint) toPixels:(b2Vec2)vec;
-(void) updateWorld;
- (void)createTarget:(NSString*)imageName
          atPosition:(CGPoint)position
            rotation:(CGFloat)rotation
            isStatic:(BOOL)isStatic;
-(void) endGame;
-(void) setUpMenu;
@end

@implementation GameLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
        [self initWorld];
        
        
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        bullets = [[NSMutableArray alloc] init];
        bulletsLocations = [[NSMutableArray alloc] init];
        enemies = [[NSMutableArray alloc] init];
		
        glClearColor(.210f, .210f, .299f, 1.0f);

        [self initDog];
        
        [self populateWithCats];
        
		
		// initialize KKInput
		KKInput* input = [KKInput sharedInput];
        input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		input.gestureLongPressEnabled = input.gesturesAvailable;
		input.gesturePanEnabled = input.gesturesAvailable;
        //input.gestureSwipeEnabled = input.gesturesAvailable;
        
        [self scheduleUpdate];
        
       // [self setUpMenu];
        
        // [self performSelector:@selector(endGame) withObject:nil afterDelay:1.2f];
    }

	return self;
}


-(void) initWorld
{
    // Construct a world object, which will hold and simulate the rigid bodies.
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    world = new b2World(gravity);
    world->SetAllowSleeping(YES);
    //world->SetContinuousPhysics(YES);
    
    //create an object that will check for collisions
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    //CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    
    b2Vec2 lowerLeftCorner =b2Vec2(0,0);
    b2Vec2 lowerRightCorner = b2Vec2(BOARD_LENGTH/PTM_RATIO,0);
    b2Vec2 upperLeftCorner = b2Vec2(0,BOARD_LENGTH/PTM_RATIO);
    b2Vec2 upperRightCorner = b2Vec2(BOARD_LENGTH/PTM_RATIO,BOARD_LENGTH/PTM_RATIO);
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    screenBorderBody = world->CreateBody(&screenBorderDef);
    
    b2EdgeShape screenBorderShape;
    b2FixtureDef screenDef;
    screenDef.shape = &screenBorderShape;
    
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    screenBorderBody->CreateFixture(&screenDef);
    
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    screenBorderBody->CreateFixture(&screenDef);
    
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    screenBorderBody->CreateFixture(&screenDef);
    
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    screenBorderBody->CreateFixture(&screenDef);
}

-(void) initDog
{
    CGRect appframe= [[UIScreen mainScreen] applicationFrame];
    
    NSLog(@"mainScreen applicationFrame: %.0f, %.0f, %3.0f, %3.0f", 
          appframe.origin.x, appframe.origin.y, appframe.size.width, appframe.size.height);
    
    //CCLOG(@"centersize: %@", centerSize);
    CGPoint center = ccp(appframe.size.width/2.0f, appframe.size.height/2.0f);
    //[self addLabels];
    
    // Add dog.
    dogSprite = [[Dog alloc] initWithDogImage];
    dogSprite.position = center;
    [self addChild:dogSprite z:0];
    // CCLOG(@"dogPos : %3.0f, %3.0f", dogSprite.position.x, dogSprite.position.y);
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody; 
    bodyDef.position.Set(dogSprite.position.y/PTM_RATIO, dogSprite.position.x/PTM_RATIO);
    
    // CCLOG(@"dogBodyPos : %3.0f, %3.0f", bodyDef.position.x, bodyDef.position.y);
    
    bodyDef.userData = (__bridge void*) dogSprite;
    dogBody = world->CreateBody(&bodyDef);
    
    b2FixtureDef boxDef;
    
    b2PolygonShape box; // Make bounding box slightly smaller than dog image
    box.SetAsBox(.65*(dogSprite.contentSize.width/2.0f)/PTM_RATIO,
                 .9*(dogSprite.contentSize.height/2.0f)/PTM_RATIO);
    //contentSize is used to determine the dimensions of the sprite
    boxDef.shape = &box;
    
    boxDef.density = 100.0f;
    boxDef.friction = 100.0f;
    boxDef.restitution = 0.1f;
    dogBody->CreateFixture(&boxDef);
}


-(void) populateWithCats
{
    CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
    
    int x = arc4random()%((int)screenSize.width);
    int y = arc4random()%((int)screenSize.height);
    secondrect = [dogSprite textureRect];
    
    while (fabsf(x - dogSprite.position.x) <= secondrect.size.width+15 &&
           fabsf(y - dogSprite.position.y) <= secondrect.size.height+15 ) {
        x = arc4random()%((int)screenSize.width);
        y = arc4random()%((int)screenSize.height);
    }
    
    [self createTarget:@"cat.png" atPosition:CGPointMake(x,y) rotation:0.0f isStatic:NO];
    
}


- (void)createTarget:(NSString*)imageName
          atPosition:(CGPoint)position
            rotation:(CGFloat)rotation
            isStatic:(BOOL)isStatic
{
   
   //Create the sprite. 
    Cat* sprite;
    sprite = [[Cat alloc] initWithCatImage];
    [self addChild:sprite z:1];
    
    //Create the bodyDef
    b2BodyDef bodyDef;
    bodyDef.type = isStatic?b2_staticBody:b2_dynamicBody; //this is a shorthand/abbreviated if-statement
    bodyDef.position.Set((position.x+sprite.contentSize.width/2.0f)/PTM_RATIO,(position.y+sprite.contentSize.height/2.0f)/PTM_RATIO);
    bodyDef.angle = CC_DEGREES_TO_RADIANS(rotation);
    bodyDef.userData = (__bridge void*) sprite;
    b2Body *body = world->CreateBody(&bodyDef);
    
    // Create the bounding box shape.
    b2PolygonShape box;
    box.SetAsBox(.9*sprite.contentSize.width/2.0f/PTM_RATIO,
                 .95*sprite.contentSize.height/2.0f/PTM_RATIO);
    //contentSize is used to determine the dimensions of the sprite
    
    b2FixtureDef boxDef;
    boxDef.shape = &box;
    //boxDef.isSensor = true;
    boxDef.friction = 25.4f;
    boxDef.userData = (void*)1;
    boxDef.density = 20.0f;
    body->CreateFixture(&boxDef);
    [enemies addObject:[NSValue valueWithPointer:body]];
    
    
}

-(void) createSmallExplosionAt:(CGPoint)location
{
	CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:50];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = YES;
	explosion.position = location;
	explosion.speed *= 4;
	[self addChild:explosion];
}


-(void) gestureRecognition
{
	KKInput* input = [KKInput sharedInput];
    if ([input isAnyTouchOnNode:menu touchPhase:KKTouchPhaseBegan])
    {
        // code for when user touched infoButton sprite goes here ...
        CCLOG(@"Pressed menu!!!!");
        return;
    }
    
	if (input.gestureTapRecognizedThisFrame)
	{
		//[self createSmallExplosionAt:input.gestureTapLocation];
        [self createBullets:input.gestureTapLocation];
	}
	
    
	if (input.gesturePanBegan )
	{
        
		//CCLOG(@"translation: %.0f, %.0f, velocity: %.1f, %.1f", input.gesturePanTranslation.x, input.gesturePanTranslation.y, input.gesturePanVelocity.x, input.gesturePanVelocity.y);
        
        // This makes sure that sprite follows drag.
        CGPoint eventualStop = input.gesturePanLocation;
        CGSize size = dogSprite.textureRect.size;
        if (fabsf(eventualStop.x - dogSprite.position.x) <= size.width &&
            fabs(eventualStop.y - dogSprite.position.y) <= size.height) {
            
            eventualStop.x = max(min(.95*(input.gesturePanLocation.x - dogSprite.position.x),MAX_SPEED), -1*MAX_SPEED);
            eventualStop.y = max(min(.95*(input.gesturePanLocation.y - dogSprite.position.y),MAX_SPEED), -1*MAX_SPEED);
            
            dogBody->SetLinearVelocity( b2Vec2( eventualStop.x, eventualStop.y ));
            dogBody->SetLinearDamping(3.0f);
        }
       
    }



	
}


-(void) update:(ccTime)delta
{
     
    // 1% chance to spawn a cat
    if ((arc4random()%100) == 0)
      [self populateWithCats];
	
	CCDirector* director = [CCDirector sharedDirector];
	
	if (director.currentPlatformIsIOS)
	{
		[self gestureRecognition];
		
		if ([KKInput sharedInput].anyTouchEndedThisFrame)
		{
			CCLOG(@"anyTouchEndedThisFrame!!!!!");
		}
	}
		
    // Update world 1 step
    float timeStep = 1.0f/60.0f;
    int32 velocityIterations = 8;
    int32 positionIterations = 2;
    world->Step(timeStep, velocityIterations, positionIterations);
    
    [self updateWorld];
    
  
}

-(void) updateWorld
{
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        //get the sprite associated with the body
        CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
        
        if (![sprite isKindOfClass:[Bullet class]]){
            body->SetLinearVelocity(0.97f*body->GetLinearVelocity());
            body->SetAngularVelocity(0);
        }
        
        if (sprite != NULL && sprite.tag==2)
        {
            if ([sprite isKindOfClass:[Cat class]])
            {
                //CCLOG(@"IS CAT");
                if( ((Cat*)sprite).health==1 )
                {
                    [self removeChild:sprite cleanup:NO];
                    world->DestroyBody(body);
                }
                else
                {
                    ((Cat*)sprite).health--;
                }
            }
            else if ([sprite isKindOfClass:[Dog class]]) {
                //CCLOG(@"IS DOG");
                if( ((Dog*)sprite).health==1 ) // Dog is dead
                {
                    [self createSmallExplosionAt:sprite.position];
                    [self removeChild:sprite cleanup:NO];
                    world->DestroyBody(body);
                    //[self endGame];
                    [self performSelector:@selector(endGame) withObject:nil afterDelay:1.2f];
                    return;
                }
                else
                {
                    ((Dog*)sprite).health--;
                    sprite.color= ccWHITE;
                }
                dogBody->SetLinearVelocity(b2Vec2(0.1f,0.1f));
            }
            else
            {
                [self removeChild:sprite cleanup:NO];
                world->DestroyBody(body);
            }
            sprite.tag = 1;
        }
        else if (sprite != NULL)
        {
            // update the sprite's position to where their physics bodies are
            sprite.position = [self toPixels:body->GetPosition()];
        }
    }
    
 }

-(void) endGame{
    
    // This is a hack that prevents KKInput from swallowing every fuckign touch.
    // God I hate this documentation.
    KKInput* input = [KKInput sharedInput];
    UITapGestureRecognizer* tapGestureRecognizer;
    tapGestureRecognizer = input.tapGestureRecognizer;
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.7f  scene:((CCScene*)[[GameOverLayer alloc] init]) ]];
}

//Create the bullets, add them to the list of bullets so they can be referred to later
- (void)createBullets:(CGPoint)location
{
   
    Bullet *bulletSprite = [[Bullet alloc] initWithBulletImage];
    bulletSprite.position = dogSprite.position;
    [self addChild:bulletSprite z:9];
    //[bullets addObject:bulletSprite];
    NSValue *value = [NSValue valueWithCGPoint:ccpSub(location, dogSprite.position)];
    [bulletsLocations addObject:value];
 
    b2BodyDef bulletBodyDef;
    bulletBodyDef.type = b2_dynamicBody;
    bulletBodyDef.bullet = true; //this tells Box2D to check for collisions more often - sets "bullet" mode on
    bulletBodyDef.position.Set(dogSprite.position.x/PTM_RATIO,dogSprite.position.y/PTM_RATIO);
    bulletBodyDef.userData = (__bridge void*)bulletSprite;
    b2Body *bullet = world->CreateBody(&bulletBodyDef);
    bullet->SetActive(false); //an inactive body does not collide with other bodies
    
    b2CircleShape circle;
    circle.m_radius = bulletSprite.size.width/PTM_RATIO; //you can figure the dimensions out by looking at flyingpenguin.png in image editing software
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.8f;
    ballShapeDef.restitution = 0.0f; //set the "bounciness" of a body (0 = no bounce, 1 = complete (elastic) bounce)
    ballShapeDef.friction = 0.99f;
    ballShapeDef.isSensor = true;
    //try changing these and see what happens!
    bullet->CreateFixture(&ballShapeDef);
    
    [bullets addObject:[NSValue valueWithPointer:bullet]];
    CGPoint translation = ccpSub(location, dogSprite.position);
    b2Vec2 direction = b2Vec2( translation.x, translation.y);
    direction.Normalize();
    bullet->SetLinearVelocity( BULLET_SPEED*direction ); 
    bullet->SetActive(true);
    
}




// TODO:Currently KKInput swallows up all touch inputs. Find out how to get around this
// Also move this menu to the top of screen rather than middle
-(void)setUpMenu
{
    CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"ship.png"
                                                         selectedImage: @"button.png"
                                                                target:self
                                                              selector:@selector(handleMenuPress:)];
    CCMenuItem *item = [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(handleMenuPress:)]; 
    
       
    // Create a menu and add your menu items to it
    menu = [CCMenu menuWithItems:menuItem1, item,nil];
    menu.isTouchEnabled = YES;
    // Arrange the menu items Horizontally
    [menu alignItemsHorizontally];
    
    // add the menu to your scene
    [self addChild:menu];

}

-(void) handleMenuPress: (CCMenuItem *) item
{
    CCLOG(@"PRESSED MENU");
}
// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

-(void) dealloc
{
	delete world;
    
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

@end

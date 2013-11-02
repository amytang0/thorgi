/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */
#include <stdlib.h>

#import "GameLayer.h"

#import "Bullet.h"
#import "Cat.h"
#import "Dog.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"

#define MAX_SPEED 15.0
#define BOARD_LENGTH 500
const float PTM_RATIO = 32.0f;

NSMutableArray *enemies;
CCSprite *enemy;
CGRect firstrect;
CGRect secondrect;

@interface GameLayer (PrivateMethods)
-(void) changeInputType:(ccTime)delta;
-(void) postUpdateInputTests:(ccTime)delta;
-(void) detectCollisions;
-(void) createBullets:(CGPoint)location;
-(void) populateWithCats;
-(void) initWorld;
-(CGPoint) toPixels:(b2Vec2)vec;
-(void) updateWorld;
- (void)createTarget:(NSString*)imageName
          atPosition:(CGPoint)position
            rotation:(CGFloat)rotation
            isStatic:(BOOL)isStatic;
-(void) endGame;
@end

@implementation GameLayer

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
		CCDirector* director = [CCDirector sharedDirector];
		CGPoint screenCenter = director.screenCenter;

		//[self addLabels];

        // Add dog.
		dogSprite = [[Dog alloc] initWithDogImage];
        dogSprite.position = screenCenter;
		[self addChild:dogSprite z:0];
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody; 
        bodyDef.position.Set((dogSprite.position.x+dogSprite.contentSize.width/2.0f)/PTM_RATIO,(dogSprite.position.y+dogSprite.contentSize.height/2.0f)/PTM_RATIO);
        bodyDef.userData = (__bridge void*) dogSprite;
        b2Body *body = world->CreateBody(&bodyDef);
        
        b2FixtureDef boxDef;
        
        b2PolygonShape box;
        box.SetAsBox(dogSprite.contentSize.width/2.0f/PTM_RATIO,
                     dogSprite.contentSize.height/2.0f/PTM_RATIO);
        //contentSize is used to determine the dimensions of the sprite
        boxDef.shape = &box;
         
        boxDef.density = 100.0f;
        boxDef.friction = 100.0f;
        boxDef.restitution = 0.1f;
        body->CreateFixture(&boxDef);
        dogBody = body;
      
		[self scheduleUpdate];
		//[self schedule:@selector(changeInputType:) interval:8.0f];
		//[self schedule:@selector(postUpdateInputTests:)];
		
		// initialize KKInput
		KKInput* input = [KKInput sharedInput];
        input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		input.gestureLongPressEnabled = input.gesturesAvailable;
		input.gesturePanEnabled = input.gesturesAvailable;
        //input.gestureSwipeEnabled = input.gesturesAvailable;
        
        [self populateWithCats];
	}

	return self;
}

-(void) initWorld
{
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    world = new b2World(gravity);
    world->SetAllowSleeping(YES);
    //world->SetContinuousPhysics(YES);
    
    //create an object that will check for collisions
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    
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

-(void) populateWithCats
{
    CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
    
    int x = arc4random()%((int)screenSize.width);
    int y = arc4random()%((int)screenSize.height);
    secondrect = [dogSprite textureRect];
    
    while (fabsf(x - dogSprite.position.x) <= secondrect.size.width+10 &&
           fabsf(y - dogSprite.position.y) <= secondrect.size.height+10 ) {
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
    box.SetAsBox(sprite.contentSize.width/2.0f/PTM_RATIO,
                 sprite.contentSize.height/2.0f/PTM_RATIO);
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



-(void) moveDogByPollingKeyboard
{
	const float kDogSpeed = 3.0f;

	KKInput* input = [KKInput sharedInput];
	CGPoint dogPosition = dogSprite.position;
	
	if ([input isKeyDown:KKKeyCode_UpArrow] ||
		[input isKeyDown:KKKeyCode_W])
	{
		dogPosition.y += kDogSpeed;
	}
	if ([input isKeyDown:KKKeyCode_LeftArrow] || 
		[input isKeyDown:KKKeyCode_A])
	{
		dogPosition.x -= kDogSpeed;
	}
	if ([input isKeyDown:KKKeyCode_DownArrow] ||
		[input isKeyDown:KKKeyCode_S])
	{
		dogPosition.y -= kDogSpeed;
	}
	if ([input isKeyDown:KKKeyCode_RightArrow] || 
		[input isKeyDown:KKKeyCode_D])
	{
		dogPosition.x += kDogSpeed;
	}

	if (([input isKeyDown:KKKeyCode_Command] ||
		 [input isKeyDown:KKKeyCode_Control]))
	{
		dogPosition = [input mouseLocation];
	}	

	dogSprite.position = dogPosition;

	if ([input isKeyDown:KKKeyCode_Slash])
	{
		dogSprite.scale += 0.03f;
	}
	else if ([input isKeyDown:KKKeyCode_Semicolon])
	{
		dogSprite.scale -= 0.03f;
	}
	
	if ([input isKeyDownThisFrame:KKKeyCode_Quote])
	{
		dogSprite.scale = 1.0f;
	}
}

-(void) changeInputType:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];

	inputType++;
    /*
	if ((inputType == kInputTypes_End) || (inputType == kGyroscopeRotationRate && input.gyroAvailable == NO))
	{
		inputType = 0;
	}
     */
	
	NSString* labelString = nil;
	switch (inputType)
	{
		case kAccelerometerValuesRaw:
			// reset back to non-deviceMotion input
			input.accelerometerActive = input.accelerometerAvailable;
			input.gyroActive = input.gyroAvailable;
			labelString = @"Using RAW accelerometer values";
			break;
		case kAccelerometerValuesSmoothed:
			labelString = @"Using SMOOTHED accelerometer values";
			break;
		case kAccelerometerValuesInstantaneous:
			labelString = @"Using INSTANTANEOUS accelerometer values";
			break;
		case kGyroscopeRotationRate:
			labelString = @"Using GYROSCOPE rotation values";
			break;
		case kDeviceMotion:
			// use deviceMotion input for this test
			input.deviceMotionActive = input.deviceMotionAvailable;
			labelString = @"Using DEVICE MOTION values";
			break;
			
		default:
			break;
	}
	
	CCLabelTTF* label = (CCLabelTTF*)[self getChildByTag:2];
	[label setString:labelString];
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
	if (input.gestureTapRecognizedThisFrame)
	{
		[self createSmallExplosionAt:input.gestureTapLocation];
        [self createBullets:input.gestureTapLocation];
	}
	
	// drag & drop ship initiated by long-press gesture
	if (input.gestureLongPressBegan)
	{
        
        CGPoint eventualStop = input.gestureLongPressLocation;
        
        eventualStop.x = max(min(.08*(input.gestureLongPressLocation.x - dogSprite.position.x),MAX_SPEED), -1*MAX_SPEED);
        eventualStop.y = max(min(.08*(input.gestureLongPressLocation.y - dogSprite.position.y),MAX_SPEED), -1*MAX_SPEED);
        //eventualStop.x = .05*(input.gestureLongPressLocation.x - ship.position.x);
        //eventualStop.y = .05*(input.gestureLongPressLocation.y - ship.position.y);
		//dog.position = ccpAdd( dog.position, eventualStop); 
        
		//dog.color = ccGREEN;
		//dog.scale = 1.25f;
        dogBody->SetLinearVelocity( b2Vec2( eventualStop.x, eventualStop.y )); 
        dogBody->SetLinearDamping(1.0f);
     
	}
	
	if (input.gesturePanBegan) 
	{
		//CCLOG(@"translation: %.0f, %.0f, velocity: %.1f, %.1f", input.gesturePanTranslation.x, input.gesturePanTranslation.y, input.gesturePanVelocity.x, input.gesturePanVelocity.y);
        
        // This makes sure that sprite follows drag.
        CGPoint eventualStop = input.gesturePanLocation;
           
        eventualStop.x = max(min(.05*(input.gesturePanLocation.x - dogSprite.position.x),MAX_SPEED), -1*MAX_SPEED);
         eventualStop.y = max(min(.05*(input.gesturePanLocation.y - dogSprite.position.y),MAX_SPEED), -1*MAX_SPEED);
        
        dogBody->SetLinearVelocity( b2Vec2( eventualStop.x, eventualStop.y )); 
        
        
        //eventualStop.y = .05*(input.gesturePanLocation.y - ship.position.y);
        
        //dog.position = ccpAdd(dog.position, eventualStop);
        //CCLOG(@"shipPosition: %.0f, %.0f", eventualStop.x, eventualStop.y);
        
    }
	
}



-(void) particleFXFollowsMouse
{
	KKInput* input = [KKInput sharedInput];
	
	particleFX.position = [input mouseLocation];
	particleFX.gravity = ccpMult([input mouseLocationDelta], 50.0f);
}

-(void) update:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	if ([input isAnyTouchOnNode:self touchPhase:KKTouchPhaseAny])
	{
        /*
		CCLOG(@"Touch: beg=%d mov=%d sta=%d end=%d can=%d",
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseBegan], 
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseMoved], 
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseStationary],
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseEnded],
			  [input isAnyTouchOnNode:self touchPhase:KKTouchPhaseCancelled]);
         */
       
        
        /*
        CCArray* touches = [KKInput sharedInput].touches;
        KKTouch* touch;
        CCARRAY_FOREACH(touches, touch)
        {
             CCLOG(@"Touch: %@",NSStringFromCGPoint(touch.location));
            // remove touch
            [[KKInput sharedInput] removeTouch:touch];
        }
        */
	}
     
    // 1% chance to spawn a cat
    if ((arc4random()%100) == 0)
      [self populateWithCats];
	
	CCDirector* director = [CCDirector sharedDirector];
	
	if (director.currentPlatformIsIOS)
	{
		[self gestureRecognition];
		
		if ([KKInput sharedInput].anyTouchEndedThisFrame)
		{
			CCLOG(@"anyTouchEndedThisFrame");
		}
	}
	else
	{
		[self moveDogByPollingKeyboard];
		//[self rotateShipWithMouseButtons];
		[self particleFXFollowsMouse];
	}
	
    // Update world 1 step
    float timeStep = 1.0f/60.0f;
    int32 velocityIterations = 8;
    int32 positionIterations = 2;
    world->Step(timeStep, velocityIterations, positionIterations);
    
    /*
    //Bullet is moving.
    for(NSInteger i = 0; i < [bullets count]; i++)
    {
        
        bulletBody = (b2Body*)[[bullets objectAtIndex:i] pointerValue]; //get next bullet in the list
         CGPoint translation = [[bulletsLocations objectAtIndex:i] CGPointValue];  
        //bulletBody->SetTransform(b2Vec2(.25*translation.x, (.25*translation.y)), 0.0f);
        //SetTransform sets the position and rotation of the bulletBody; the syntax is SetTransform( (b2Vec2) position, (float) rotation)
        
        bulletBody->SetActive(true);
}
     */
    [self updateWorld];
    
  
}

-(void) updateWorld
{
    /*
    CCLOG(@"a!!!!!!!!!!!");
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext()) {
         CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
    CCLOG(@"body: %@, %d", NSStringFromCGPoint(sprite.position), sprite.tag);
   }
    CCLOG(@"b!!!!!!!!!!!");
     */
    //get all the bodies in the world
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
                CCLOG(@"IS CAT");
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
                CCLOG(@"IS DOG");
                if( ((Dog*)sprite).health==1 ) // Dog is dead
                {
                    [self removeChild:sprite cleanup:NO];
                    world->DestroyBody(body);
                    [self endGame];
                }
                else
                {
                    ((Dog*)sprite).health--;
                    sprite.color= ccWHITE;
                }
                
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
            if ([sprite isKindOfClass:[Dog class]]) {
                //dogSprite = sprite;
            }
                //float angle = body->GetAngle();
            //sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
        }
    }
    
 }

-(void) endGame{
    
  // [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameOverLayer alloc] init]];
}

-(void) postUpdateInputTests:(ccTime)delta
{
	KKInput* input = [KKInput sharedInput];
	if ([input anyTouchEndedThisFrame] || [input isAnyKeyUpThisFrame])
	{
		CCLOG(@"touch ended / key up this frame");
	}
}

-(void) draw
{
	KKInput* input = [KKInput sharedInput];
	if (input.touchesAvailable)
	{
		NSUInteger color = 0;
		KKTouch* touch;
		CCARRAY_FOREACH(input.touches, touch)		
		{
			switch (color)
			{
				case 0:
					ccDrawColor4F(0.2f, 1, 0.2f, 0.5f);
					break;
				case 1:
					ccDrawColor4F(0.2f, 0.2f, 1, 0.5f);
					break;
				case 2:
					ccDrawColor4F(1, 1, 0.2f, 0.5f);
					break;
				case 3:
					ccDrawColor4F(1, 0.2f, 0.2f, 0.5f);
					break;
				case 4:
					ccDrawColor4F(0.2f, 1, 1, 0.5f);
					break;
					
				default:
					break;
			}
			color++;
			
			ccDrawCircle(touch.location, 60, 0, 16, NO);
			ccDrawCircle(touch.previousLocation, 30, 0, 16, NO);
			ccDrawColor4F(1, 1, 1, 1);
			ccDrawLine(touch.location, touch.previousLocation);
			
			if (CCRANDOM_0_1() > 0.98f)
			{
				//[input removeTouch:touch];
			}
		}
	}
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
    //[bullets addObject:bulletSprite];
 
    
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
    bullet->SetLinearVelocity( b2Vec2( .08*ccpSub(location, dogSprite.position).x, .08*ccpSub(location, dogSprite.position).y) ); 
    bullet->SetActive(true);
    

    //CCLOG(@"original: %@",value);
}

-(void)setUpMenu
{
    CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"menubutton.png"
                                                         selectedImage: @"menubutton_selected.png"
                                                                target:self
                                                              selector:@selector(muteMusic:)];
    CCMenuItem *item = [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(goToLevelSelect:)]; 
    
    CCMenuItemImage * menuItem2 = [CCMenuItemImage itemWithNormalImage:@"mutesoundbutton.png"
                                                         selectedImage: @"mutesoundbutton_selected.png"
                                                                target:self
                                                              selector:@selector(muteSound:)]; 
    
    
    // Create a menu and add your menu items to it
    CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, item, menuItem2,nil];
    
    // Arrange the menu items Horizontally
    [myMenu alignItemsHorizontally];
    
    // add the menu to your scene
    [self addChild:myMenu];

}


// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}


-(void) dealloc
{   
    //delete world;
    
   // world = NULL;   
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}


@end

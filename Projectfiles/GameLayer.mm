/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */
#include <stdlib.h>

#import "GameLayer.h"


#import "Cat.h"
#import "Dog.h"
#import "SimpleAudioEngine.h"

#define MAX_SPEED 15.0
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
		
		//glClearColor(0.698f, 0.745f, 0.561f, 1.0f);
        glClearColor(.210f, .210f, .299f, 1.0f);
		CCDirector* director = [CCDirector sharedDirector];
		CGPoint screenCenter = director.screenCenter;

		//[self addLabels];

		dog = [[Dog alloc] initWithDogImage];
		dog.position = screenCenter;
		[self addChild:dog z:0];
        
       
      
		[self scheduleUpdate];
		[self schedule:@selector(changeInputType:) interval:8.0f];
		[self schedule:@selector(postUpdateInputTests:)];
		
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
    b2Vec2 lowerRightCorner = b2Vec2(screenSize.width/PTM_RATIO,0);
    b2Vec2 upperLeftCorner = b2Vec2(0,screenSize.height/PTM_RATIO);
    b2Vec2 upperRightCorner = b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO);
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    screenBorderBody = world->CreateBody(&screenBorderDef);
    b2EdgeShape screenBorderShape;
    
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
    
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0);
}

-(void) populateWithCats
{
    CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
    
    Cat *cat = [[Cat alloc] initWithCatImage];
    int x = arc4random()%((int)screenSize.width);
    int y = arc4random()%((int)screenSize.height);
    
    secondrect = [dog textureRect];

    while (fabsf(x - dog.position.x) <= secondrect.size.width+10 &&
           fabsf(y - dog.position.y) <= secondrect.size.height+10 ) {
         x = arc4random()%((int)screenSize.width);
         y = arc4random()%((int)screenSize.height);
    }
    cat.position = CGPointMake(x,y);
    [enemies addObject:cat];
    [self addChild:cat z:7];
    
}


-(void) moveDogByPollingKeyboard
{
	const float kDogSpeed = 3.0f;

	KKInput* input = [KKInput sharedInput];
	CGPoint dogPosition = dog.position;
	
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

	dog.position = dogPosition;

	if ([input isKeyDown:KKKeyCode_Slash])
	{
		dog.scale += 0.03f;
	}
	else if ([input isKeyDown:KKKeyCode_Semicolon])
	{
		dog.scale -= 0.03f;
	}
	
	if ([input isKeyDownThisFrame:KKKeyCode_Quote])
	{
		dog.scale = 1.0f;
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
	dog.color = ccWHITE;
	dog.scale = 1.0f;
	if (input.gestureLongPressBegan)
	{
        
        CGPoint eventualStop = input.gestureLongPressLocation;
        eventualStop.x = max(min(.08*(input.gestureLongPressLocation.x - dog.position.x),MAX_SPEED), -1*MAX_SPEED);
        eventualStop.y = max(min(.08*(input.gestureLongPressLocation.y - dog.position.y),MAX_SPEED), -1*MAX_SPEED);
        //eventualStop.x = .05*(input.gestureLongPressLocation.x - ship.position.x);
        //eventualStop.y = .05*(input.gestureLongPressLocation.y - ship.position.y);
		dog.position = ccpAdd( dog.position, eventualStop); 
        
		dog.color = ccGREEN;
		dog.scale = 1.25f;
     
	}
	
	if (input.gesturePanBegan) 
	{
		//CCLOG(@"translation: %.0f, %.0f, velocity: %.1f, %.1f", input.gesturePanTranslation.x, input.gesturePanTranslation.y, input.gesturePanVelocity.x, input.gesturePanVelocity.y);
        
        // This makes sure that sprite follows drag.
        CGPoint eventualStop = input.gesturePanLocation;
        eventualStop.x = max(min(.05*(input.gesturePanLocation.x - dog.position.x),MAX_SPEED), -1*MAX_SPEED);
         eventualStop.y = max(min(.05*(input.gesturePanLocation.y - dog.position.y),MAX_SPEED), -1*MAX_SPEED);
        //eventualStop.y = .05*(input.gesturePanLocation.y - ship.position.y);
        dog.position = ccpAdd(dog.position, eventualStop);
        //CCLOG(@"shipPosition: %.0f, %.0f", eventualStop.x, eventualStop.y);
        
    }
	
}


-(void) wrapShipAtScreenBorders
{
	CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
	
	CGPoint dogPosition = dog.position;

	if (dogPosition.x < 0)
	{
		dogPosition.x += screenSize.width;
	}
	else if (dogPosition.x >= screenSize.width)
	{
		dogPosition.x -= screenSize.width;
	}
	
	if (dogPosition.y < 0)
	{
		dogPosition.y += screenSize.height;
	}
	else if (dogPosition.y >= screenSize.height)
	{
		dogPosition.y -= screenSize.height;
	}
	
	dog.position = dogPosition;
	//LOG_EXPR(ship.texture);
	//LOG_EXPR([ship boundingBox]);
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
	
    // TODO: Hopefully replace with camera following you around map
	[self wrapShipAtScreenBorders];

    NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
    
    //Move the projectiles to the tap point
    for(NSInteger i = 0; i < [bullets count]; i++)
    {
        
        CCSprite *projectile = [bullets objectAtIndex:i];
        CGPoint projPos = projectile.position;
        CGPoint point = [ [bulletsLocations objectAtIndex:i] CGPointValue];  
        //CCLOG(@"projectile: %@ ; point: %@", NSStringFromCGPoint(projPos), NSStringFromCGPoint(point));
        CGPoint step = CGPointMake(0, 0);
        
        //CCLOG(@"%f %f %f %f",projPos.x ,point.x , projPos.y, point.y);
                
        // Add indexes of bullets to be removed.
        // Bullets are candidates if they reached outside the screen.
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (projPos.x <= 0 || projPos.y <= 0 || 
            projPos.x >= screenBounds.size.height || projPos.y >= screenBounds.size.width
             ) {
            [indexesToDelete addIndex:i];
            [self removeChild:projectile cleanup:true];
           //  CCLOG(@"points are outside");
    
        } else {
        //Move bullets if they haven't.
        step.x = .05*(point.x);
        step.y = .05*(point.y);
         //   step.x = .05*(point.x - dog.position.x);
          //  step.y = .05*(point.y - dog.position.y);
        projectile.position = ccpAdd( projectile.position, step); 
        }

    }
    
    // Finally safely remove bullets and their locations.
    [bulletsLocations removeObjectsAtIndexes:indexesToDelete];
    [bullets removeObjectsAtIndexes:indexesToDelete];
    
    
    //If there are bullets and blocks in existence, check if they are colliding
    if([bullets count] > 0 && [enemies count] > 0)
    {
        CCLOG(@"is detecting collisions");
        [self detectCollisions];
    }
     
    /*
    // Update world 1 step
    float timeStep = 0.03f;
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    world->Step(timeStep, velocityIterations, positionIterations);
    
    //Bullet is moving.
    for(NSInteger i = 0; i < [bullets count]; i++)
    {
        
        bulletBody = (b2Body*)[[bullets objectAtIndex:i] pointerValue]; //get next bullet in the list
         CGPoint translation = [[bulletsLocations objectAtIndex:i] CGPointValue];  
        bulletBody->SetTransform(b2Vec2(.05*translation.x/PTM_RATIO, (.05*translation.y)/PTM_RATIO), 0.0f);
        //SetTransform sets the position and rotation of the bulletBody; the syntax is SetTransform( (b2Vec2) position, (float) rotation)
        
        bulletBody->SetActive(true);

        
        b2Vec2 position = bulletBody->GetPosition();
        
        CGPoint myPosition = self.position;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // Move the camera.
        if (position.x > screenSize.width / 2.0f / PTM_RATIO)
            //if the bullet is past the edge of the screen
        {
            //self.position refers to the window's position - subtracting from self.position moves the screen to the right
            //meaning that the screen position is negative as it moves
            //only shift the screen a maximum of one screen size to the right
            myPosition.x = -MIN(screenSize.width * 2.0f - screenSize.width, position.x * PTM_RATIO - screenSize.width / 2.0f);
            self.position = myPosition;
            
        }
    }
     */
    
  
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
    CCSprite *bulletSprite = [CCSprite spriteWithFile:@"fire.png"];
    bulletSprite.position = dog.position;
    [self addChild:bulletSprite z:9];
    //[bullets addObject:bulletSprite];
    NSValue *value = [NSValue valueWithCGPoint:ccpSub(location, dog.position)];
    [bulletsLocations addObject:value];
    [bullets addObject:bulletSprite];
 
    /*
    b2BodyDef bulletBodyDef;
    bulletBodyDef.type = b2_dynamicBody;
    bulletBodyDef.bullet = true; //this tells Box2D to check for collisions more often - sets "bullet" mode on
    bulletBodyDef.position.Set(dog.position.x,dog.position.y);
    bulletBodyDef.userData = (__bridge void*)bulletSprite;
    b2Body *bullet = world->CreateBody(&bulletBodyDef);
    bullet->SetActive(false); //an inactive body does not collide with other bodies
    
    b2CircleShape circle;
    circle.m_radius = 12.0/PTM_RATIO; //you can figure the dimensions out by looking at flyingpenguin.png in image editing software
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.8f;
    ballShapeDef.restitution = 0.0f; //set the "bounciness" of a body (0 = no bounce, 1 = complete (elastic) bounce)
    ballShapeDef.friction = 0.99f;
    //try changing these and see what happens!
    bullet->CreateFixture(&ballShapeDef);
    
    [bullets addObject:[NSValue valueWithPointer:bullet]];
    
    */
    
    

    //CCLOG(@"original: %@",value);
}

//Check through all the bullets and blocks and see if they intersect
-(void) detectCollisions
{
    
    NSMutableIndexSet *bulletIndexesToDelete = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *enemyIndexesToDelete = [NSMutableIndexSet indexSet];
    for(int i = 0; i < [bullets count]; i++)
    {
        for(int j = 0; j < [enemies count]; j++)
        {
            if([bullets count]>0)
            {
                NSInteger bulletI = i;
                NSInteger enemyI = j;
                
                enemy = [enemies objectAtIndex:enemyI];
                CCSprite *projectile = [bullets objectAtIndex:bulletI];
                
                CCLOG(@"%@ %@", enemy, projectile);
                
                firstrect = [projectile textureRect];
                secondrect = [enemy textureRect];
                //check if their x coordinates match
               // CCLOG(@"proectilePos: %@ ;enemypos:%@",projectile.position, enemy.position);
                CCLOG(@"first: %d, second: %d", i, j);
               
                CGPoint projPos = projectile.position;
                CGPoint enemyPos = enemy.position;
                //CCLOG(@"proectilePos %d: %@" ,i, NSStringFromCGPoint(projPos));
                //CCLOG(@"enemy % d: %@", j, NSStringFromCGPoint(enemyPos));
                //CCLOG(@"%f %f", projPos.x, projPos.y);
                //CCLOG(@"enemy %f %f", enemyPos.x, enemyPos.y);
                //CCLOG(@"%f %f", secondrect.size.width, secondrect.size.height);

                if( fabsf(projPos.x - enemyPos.x) <= secondrect.size.width/2 &&
                    fabsf(projPos.y - enemyPos.y) <= secondrect.size.height/2)
                {
                  //  CCLOG(@"projectile hit enemy");

              
                    if([enemy isKindOfClass:[Cat class]]) {
                        
                        //the program doesn't know that the block is actually a Cat object; we must cast it to a cat
                        if (((Cat*)enemy).health==1)
                        {
                            [self removeChild:enemy cleanup:YES];
                            [self removeChild:projectile cleanup:YES];
                            [enemyIndexesToDelete addIndex:enemyI];
                        }
                        else
                        {
                            ((Cat*)enemy).health--;
                            [self removeChild:projectile cleanup:YES];
                        }
                    } else {
                        [self removeChild:enemy cleanup:YES];
                        [self removeChild:projectile cleanup:YES];
                        [enemyIndexesToDelete addIndex:enemyI];
                        
                    }
                    [bulletIndexesToDelete addIndex:bulletI];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
                
                }
            }
            
        }
        
    }
    
    // Remove bullets and enemies
    [bullets removeObjectsAtIndexes:bulletIndexesToDelete];
    [bulletsLocations removeObjectsAtIndexes:bulletIndexesToDelete];
    [enemies removeObjectsAtIndexes:enemyIndexesToDelete];
}

-(void) detectDogHit
{
    for(int enemyI = 0; enemyI < [enemies count]; enemyI++) {
        enemy = [enemies objectAtIndex:enemyI];
        secondrect = [dog textureRect];
        
        if( fabsf(dog.position.x - enemy.position.x) <= secondrect.size.width/2 &&
           fabsf(dog.position.y - enemy.position.y) <= secondrect.size.height/2)
        {
            dog.health--;
        }

    }
}

-(void) dealloc
{
    
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}


@end

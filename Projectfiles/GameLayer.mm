/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */
#include <stdlib.h>

#import "GameLayer.h"
#import "Box2DDebugLayer.h"

#import "cocos2d.h"

#import "Bullet.h"
#import "Cat.h"
#import "Dog.h"
#import "GameOverLayer.h"
#import "HUDLayer.h"
#import "SimpleAudioEngine.h"


#define MAX_SPEED 15.0f
#define BOARD_LENGTH 1000
#define BULLET_SPEED 15.0f
#define INVINCIBILITY 2.0f
#define MAX_CATS 30

const float PTM_RATIO = 32.0f;
//#define PTM_RATIO 32.0f
CCSpriteBatchNode *bullets;
CCSpriteBatchNode *basicCats;
CCSpriteBatchNode *wizardCats;

@interface GameLayer (PrivateMethods)
-(void) changeInputType:(ccTime)delta;
-(void) postUpdateInputTests:(ccTime)delta;
-(void) createBullets:(CGPoint)location;
-(void) populateWithCats;
-(void) initWorld;
-(void) initDog;
-(CGPoint) toPixels:(b2Vec2)vec;
-(void) updateWorld;
- (void)createCat:(NSString*)imageName
          atPosition:(CGPoint)position
            rotation:(CGFloat)rotation
            isStatic:(BOOL)isStatic;
-(void) endGame;
//-(void) setUpMenu;
@end

@implementation GameLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
     //HUDLayer *hud = [HUDLayer node];
    HUDLayer *hud = [[HUDLayer alloc]init];
    [scene addChild:hud z:10];
	// 'layer' is an autorelease object.
	GameLayer *layer = [[GameLayer alloc] initWithHUD:hud];
	// add layer as a child to scene
	[scene addChild: layer z:0];
	// return the scene
	return scene;
}

// Replace beginning of init with the following
- (id)initWithHUD:(HUDLayer *)hudLayer
{
    if ((self = [super init])) {
        
        [[CCDirector sharedDirector] setDisplayFPS:YES];
        // Add the HUD layer on top.
        [self initHud: hudLayer];
        //hud = hudLayer;
        
        [self initWorld];
               
        [self initSpriteSheets];
        
        [self initSoundsAndMusic];
        
        CCSprite *bg = [[CCSprite alloc] initWithFile:@"background.png"];
        bg.scale=10;
        [self addChild:bg z:-10];
        
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        //bullets = [[NSMutableArray alloc] init];
        //bulletsLocations = [[NSMutableArray alloc] init];
        //enemies = [[NSMutableArray alloc] init];
        score = 0;
		
        glClearColor(.210f, .210f, .299f, 1.0f);

        [self initDog];
		
		// initialize KKInput
		KKInput* input = [KKInput sharedInput];
        input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		input.gestureLongPressEnabled = input.gesturesAvailable;
		input.gesturePanEnabled = input.gesturesAvailable;
        //input.gestureSwipeEnabled = input.gesturesAvailable;
        
        self.isTouchEnabled = YES;
        
        [self scheduleUpdate];
        
        //[self setUpMenu];
        
       // for(int i=0; i < MAX_CATS; i++)
       // [self populateWithCats];
        
        //Has camera follow
         CGRect rect = CGRectMake(0, 0, BOARD_LENGTH, BOARD_LENGTH);
          [self runAction:[CCFollow actionWithTarget:dogSprite worldBoundary:rect]];
        //[self runAction:[CCFollow actionWithTarget:dogSprite]];
        //[self->hud runAction:[CCFollow actionWithTarget:self]];
        
        [self enableBox2dDebugDrawing];

    }

	return self;
}


-(void) initSoundsAndMusic
{
    SimpleAudioEngine *engine = [SimpleAudioEngine sharedEngine];
    [engine preloadBackgroundMusic:@"StarshipThorgi.wav"];
    [engine playBackgroundMusic:@"StarshipThorgi.wav" loop:YES];
    [engine setBackgroundMusicVolume:0.5f];
    [engine preloadEffect:@"pew.wav"];
    [engine preloadEffect:@"Pow.caf"];
}

-(void) initHud: (HUDLayer*)hudLayer
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self->hud = hudLayer;
   // self->hud.position=ccp(0,winSize.height-2*hudLayer.size.height);
    self->hud.position=ccp(0,winSize.height-40);
    //self->hud.position = ccp(-winSize.height/2, winSize.height);
   // self->hud.position = ccp(0,0);
  //  [self->hud runAction:[CCFollow actionWithTarget:dogSprite]];
    [self addChild:hud z:100];
}

-(void) initSpriteSheets
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spottedcatsprite.plist"];
    basicCats = [CCSpriteBatchNode batchNodeWithFile:@"spottedcatsprite.png"];
    [self addChild:basicCats];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizardcatsprite.plist"];
    wizardCats = [CCSpriteBatchNode batchNodeWithFile:@"wizardcatsprite.png"];
    [self addChild:wizardCats];
    
    bullets = [CCSpriteBatchNode batchNodeWithFile:@"fire.png"];
    [self addChild:bullets];
}


-(void) initWorld
{
    // Construct a world object, which will hold and simulate the rigid bodies.
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    world = new b2World(gravity);
    world->SetAllowSleeping(YES);
    //world->SetContinuousPhysics(YES);
    
    // Create an object that will check for collisions.
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    screenBorderBody = world->CreateBody(&screenBorderDef);
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //b2EdgeShape screenBorderShape;  //This is line.
    b2PolygonShape box; //This is box.
    box.SetAsBox(winSize.width/2.0f/PTM_RATIO,
                 winSize.height/2.0f/PTM_RATIO);
    
    
    //Vertices must be in counter-clockwise order.
    // Making right border.
    b2Vec2 vertices[] = {
        b2Vec2(0,0),
      b2Vec2(0,BOARD_LENGTH/PTM_RATIO),
        b2Vec2(-winSize.width/2/PTM_RATIO, BOARD_LENGTH/PTM_RATIO),
          b2Vec2(-winSize.width/2/PTM_RATIO,0)
        
    };
    box.Set(vertices, 4);
    
    b2FixtureDef screenDef;
    screenDef.shape = &box;
    screenBorderBody->CreateFixture(&screenDef);
    
    // Making top border.
    b2Vec2 vertices2[] = {
        b2Vec2((-winSize.width/2)/PTM_RATIO,(BOARD_LENGTH+winSize.height/2)/PTM_RATIO),
        b2Vec2(-winSize.width/2/PTM_RATIO, BOARD_LENGTH/PTM_RATIO),
        b2Vec2((BOARD_LENGTH +winSize.width/2)/PTM_RATIO,BOARD_LENGTH/PTM_RATIO),
        b2Vec2((BOARD_LENGTH +winSize.width/2)/PTM_RATIO,(BOARD_LENGTH+winSize.height/2)/PTM_RATIO),
        
    };
    box.Set(vertices2, 4);
    screenDef.shape = &box;
    screenBorderBody->CreateFixture(&screenDef);
    
    
    // Making left border.
    b2Vec2 vertices3[] = {
        b2Vec2((BOARD_LENGTH +winSize.width/2)/PTM_RATIO,0),
        b2Vec2((BOARD_LENGTH +winSize.width/2)/PTM_RATIO,BOARD_LENGTH/PTM_RATIO),
        b2Vec2((BOARD_LENGTH)/PTM_RATIO,BOARD_LENGTH/PTM_RATIO),
        b2Vec2(BOARD_LENGTH/PTM_RATIO,0),
    };
    box.Set(vertices3, 4);
    screenDef.shape = &box;
    screenBorderBody->CreateFixture(&screenDef);
    
    // Making bottom border.
    b2Vec2 vertices4[] = {
        b2Vec2((BOARD_LENGTH +winSize.width/2)/PTM_RATIO,0),
        b2Vec2((-winSize.width/2)/PTM_RATIO,0),
        b2Vec2((-winSize.width/2)/PTM_RATIO,-winSize.height/2/PTM_RATIO),
        b2Vec2((BOARD_LENGTH + winSize.width/2)/PTM_RATIO,-winSize.height/2/PTM_RATIO),
    };
    box.Set(vertices4, 4);
    screenDef.shape = &box;
    screenBorderBody->CreateFixture(&screenDef);
    


}

-(void) initDog
{
    CGRect appframe= [[UIScreen mainScreen] applicationFrame];
    
   // NSLog(@"mainScreen applicationFrame: %.0f, %.0f, %3.0f, %3.0f",
   //       appframe.origin.x, appframe.origin.y, appframe.size.width, appframe.size.height);
    
    //CCLOG(@"centersize: %@", centerSize);
    //CGPoint center = ccp(appframe.size.width/2.0f, appframe.size.height/2.0f);
    CGPoint center = ccp(BOARD_LENGTH/2.0f, BOARD_LENGTH/2.0f);
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
    dogBody->SetFixedRotation(YES);
}


-(void) populateWithCats
{
    CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
    //int width = (int)screenSize.width;
    //int height = (int)screenSize.height;
    
    // Use this one once big board is implemented.
    int width = BOARD_LENGTH*2;
    int height = BOARD_LENGTH*2;
    float ratio = (1.0f*BOARD_LENGTH)/(1.0f*screenSize.width);
    CGPoint dogPos = ccp(dogSprite.boundingBoxCenter.x * ratio, dogSprite.boundingBoxCenter.y * ratio);
    //CCLOG(@"ratio: %f. dogpos: %@", ratio,NSStringFromCGPoint(dogPos));
    //CGPoint dogPos = [self getScreenPosition:dogSprite.position];
    //CGPoint dogPos = ccpSub([self toPixels: dogBody->GetPosition()], self.position);
    int x = arc4random()%width;
    int y = arc4random()%height;
    
    //int i = 0;
    //Makes sure it doesn't hit dog immediately
    float distance = fabsf(hypotf(x - dogPos.x, y - dogPos.y));
    //while (fabsf(x - dogPos.x) <= 350 &&
    //       fabsf(y - dogPos.y) <= 200 ) {
    while (distance <= 300) {
        //CCLOG(@"in for loop");
        x = arc4random()%width;
        y = arc4random()%height;
        distance = hypotf(x - dogPos.x, y - dogPos.y);
        /*
        //Puts this at the edges
        if(x%4 == 0) {
            x = screenSize.width;
        } else if (x%4 == 1){
            y = screenSize.height;
        } else if (x%3 == 2) {
            x = 0+20;
        } else {
            y = 0+20;
        }
         */
    }
    //CCLOG(@"WAS IN WHILE LOOP FOR: %d", i);
    
    //CGPoint p = [self getScreenPosition:CGPointMake(x,y)];
    CGPoint p = ccp(x,y);
    CCLOG(@"POINT: %@", NSStringFromCGPoint(p));
    [self createCat:@"cat.png" atPosition:p rotation:0.0f isStatic:NO];
    
}


- (void)createCat:(NSString*)imageName
          atPosition:(CGPoint)position
            rotation:(CGFloat)rotation
            isStatic:(BOOL)isStatic
{
    CCSprite *sprite;
        int random = arc4random();
    if (score >= 10 && random%10 <1) {
        sprite =[[WizardCat alloc] initWithAnimatedCat];
        [wizardCats addChild:sprite z:1];
    } else {
    
   //Create the sprite.
    
    //sprite = [[Cat alloc] initWithCatImage];
        if (score > 25 && random%10 >= 3) {
          sprite = [[DashCat alloc] initWithAnimatedCat];
        } else {
            
            sprite =[[Cat alloc] initWithAnimatedCat];
        }
      [basicCats addChild:sprite z:1];
    }
    
    //Create the bodyDef
    b2BodyDef bodyDef;
    bodyDef.type = isStatic?b2_staticBody:b2_dynamicBody; //this is a shorthand/abbreviated if-statement
    bodyDef.position.Set((position.x/2.0f)/PTM_RATIO,(position.y/2.0f)/PTM_RATIO);
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
    body->SetFixedRotation(YES);
    //[enemies addObject:[NSValue valueWithPointer:body]];
    //[self addChild:[NSValue valueWithPointer:body]];
    
    
}

-(void) createExplosionAt:(CGPoint)location
{
	CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:100];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = YES;
	explosion.position = location;
	explosion.speed *= 4;
	[self addChild:explosion];
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
    explosion.life = 0.01f;
    ccColor4F color = ccc4f(0, .2f, .8f, 1);
    explosion.startColor = color;
    [self addChild:explosion];
}

-(CGPoint) getScreenPosition:(CGPoint)point
{
    point.x -= self.position.x;
    point.y -= self.position.y;
    return point;
}

-(void) gestureRecognition
{
	KKInput* input = [KKInput sharedInput];
    //CCLOG(@"detected touch on gamelayer");
    
    if ([input isAnyTouchOnNode:hud touchPhase:KKTouchPhaseBegan])
    {
        // code for when user touched infoButton sprite goes here ...
        CCLOG(@"Pressed menu!!!!");
      //  CGPoint tapped =[input gestureTapLocation];
         [self stopTakingKKInput];
      //  [hud handleTouch: tapped];
       
        return;
        
    }
     
    
	if (input.gestureTapRecognizedThisFrame)
	{
        //[self createBullets:input.gestureTapLocation];
       // CCLOG(@"tapLoc: %@, %@", NSStringFromCGPoint(input.gestureTapLocation),NSStringFromCGPoint( dogSprite.position));
        //CGPoint point = ccpAdd(input.gestureTapLocation, dogSprite.position);
       // CGPoint point = [[CCDirector sharedDirector] convertToGL:input.gestureTapLocation];
       
        CGPoint point = [self getScreenPosition:input.gestureTapLocation];
      //  CCLOG(@"tapLoc: %@", NSStringFromCGPoint(point));
      
        [self createBullets:point];
        
	}
	
    
	if (input.gesturePanBegan )
	{
        
		//CCLOG(@"gesturetranslation: %.0f, %.0f, velocity: %.1f, %.1f", input.gesturePanTranslation.x, input.gesturePanTranslation.y, input.gesturePanVelocity.x, input.gesturePanVelocity.y);
        
        /*
        // This makes sure that sprite follows drag.
        CGPoint eventualStop = input.gesturePanLocation;
        CGSize size = dogSprite.textureRect.size;
        if (fabsf(eventualStop.x - dogSprite.position.x) <= size.width/2+10 &&
            fabs(eventualStop.y - dogSprite.position.y) <= size.height/2+10) {
            
            //eventualStop.x = max(min(.95*(input.gesturePanLocation.x - dogSprite.position.x),MAX_SPEED), -1*MAX_SPEED);
            //eventualStop.y = max(min(.95*(input.gesturePanLocation.y - dogSprite.position.y),MAX_SPEED), -1*MAX_SPEED);
            eventualStop.x = .90*(input.gesturePanLocation.x - dogSprite.position.x);
            eventualStop.y = .90*(input.gesturePanLocation.y - dogSprite.position.y);
            
            dogBody->SetLinearVelocity( b2Vec2( eventualStop.x, eventualStop.y ));
            dogBody->SetLinearDamping(3.0f);
        }
         
         */
        
        float speed = pow(input.gesturePanVelocity.x, 2) + pow(input.gesturePanVelocity.y, 2);
        speed = pow(speed, .5);
        //CCLOG(@"speed %f", speed);
      
        //CCLOG(@"panVelocity %@", NSStringFromCGPoint(input.gesturePanVelocity));
        CGPoint pan = [self getScreenPosition:input.gesturePanLocation];
        CGPoint eventualStop = pan;
        eventualStop.x = .90*(pan.x - dogSprite.position.x);
        eventualStop.y = .90*(pan.y - dogSprite.position.y);
        b2Vec2 vector = b2Vec2( eventualStop.x, eventualStop.y );
        vector.Normalize();
        vector*=(.5*speed + .5*10);
        
        dogBody->SetLinearVelocity( vector);
       
        /*b2Vec2 velocity = b2Vec2(input.gesturePanVelocity.x, -1*input.gesturePanVelocity.y);
        //velocity.Normalize();
        //velocity*=10;
        dogBody->SetLinearVelocity( velocity);
         */
        dogBody->SetLinearDamping(3.0f);
       
    }

	
}


-(void) update:(ccTime)delta
{
     
    // 1% chance to spawn a cat
    if ((arc4random()%100) < 1)
      [self populateWithCats];
	
	CCDirector* director = [CCDirector sharedDirector];
	
	if (director.currentPlatformIsIOS)
	{
		[self gestureRecognition];
		
		if ([KKInput sharedInput].anyTouchEndedThisFrame)
		{
			//CCLOG(@"anyTouchEndedThisFrame!!!!!");
		}
	}
		
    // Update world 1 step
    float timeStep = 1.0f/60.0f;
    int32 velocityIterations = 8;
    int32 positionIterations = 2;
    world->Step(timeStep, velocityIterations, positionIterations);
    
    [self updateWorld];
    [self moveCats];
    [self updateHUD];
    
    
}

-(void) updateHUD
{
    //NSString *scoreString = [NSString stringWithFormat:@"Score: %d",score];
    //[hud setScoreString:scoreString];
    CGSize winSize = [CCDirector sharedDirector].winSize;
    hud.position = [self getScreenPosition:ccp(0,winSize.height-40)];
    [hud setScore:score];
    [hud setLives:dogSprite.health];
}

-(void) moveCats
{
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
        if ([sprite isKindOfClass:[Cat class]]){
            Cat* cat = (Cat*)sprite;
            b2Vec2 velocity = b2Vec2(dogSprite.boundingBoxCenter.x-sprite.boundingBoxCenter.x,dogSprite.boundingBoxCenter.y- sprite.boundingBoxCenter.y);
            velocity.Normalize();
            //b2Vec2 oldVelocity = body->GetLinearVelocity();
            //oldVelocity.Normalize();
            //CGFloat oldAngle = [self getAngleFromVelocity:oldVelocity];
            //CGFloat newAngle = [self getAngleFromVelocity:velocity];
                               
            
            if ([cat isKindOfClass:[DashCat class]]){
                DashCat *dashCat = (DashCat *)cat;
                if (dashCat.velocity.Length() == 0 && dashCat.speed != 0) { // not moving but about to dash
                    dashCat.velocity = velocity;
                } else {
                    velocity = dashCat.velocity;
                }
            }
            
            body->SetLinearVelocity(((Cat*)sprite).speed*velocity);
            
            
            [self setWalkDirection:[self getDirectionFromVelocity:body->GetLinearVelocity()] sprite:cat];
            
            body->SetAngularVelocity(0);
        }
    }
}

-(void) setWalkDirection: (NSString*)d sprite:(Cat*)cat
{
    
    //CCLOG(@"%@ moving in direction %@, from old dire: %@", self, d, self.direction);
    
     if ([cat.direction isEqualToString:d]) {
     return;
     }
     
    [cat stopAction:cat.moveAction];
    
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    NSString *catType = @"";
    if([cat isKindOfClass:[WizardCat class]]){
        catType = @"wizard";
    }
    
    for (int i = 1; i <= 3; i++){
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@cat%d.png",d,catType,i];
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          fileName]];
        
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    cat.moveAction = [CCRepeatForever actionWithAction:
                  [CCAnimate actionWithAnimation:walkAnim]];
    [cat runAction:cat.moveAction];
    cat.direction = d;
    
}





-(CGFloat) getAngleFromVelocity: (b2Vec2)velocity
{
    CGFloat angle = atan2(velocity.y,velocity.x)*180.0f/M_PI;
    if (angle < 0) angle+=360;
    return angle;
}

-(NSString*) getDirectionFromVelocity: (b2Vec2)velocity
{
   // CGFloat angle = atan2(velocity.y,velocity.x)*180.0f/M_PI;
    CGFloat angle = [self getAngleFromVelocity:velocity];
    
    if (angle > 45 && angle < 135) {
        
        return @"back";
    } else if (angle >= 135 && angle <= 225) {
        return @"left";
    } else if (angle > 225 && angle < 360){
        return @"front";
    } else {
        return @"right";
    }
}

-(NSString*) getDirectionFromPositions: (CGPoint)cat
{
    CGFloat x = dogSprite.boundingBoxCenter.x - cat.x;
    CGFloat y = dogSprite.boundingBoxCenter.y - cat.y;
    
    CCLOG(@"%f, %f", x,y);
    if (x > 0 && fabsf(x)>=fabsf(y))
        return @"right";
    else if (x <= 0 && fabsf(x)>=fabsf(y))
        return @"left";
    else if (y > 0)
        return @"back";
    else
        return @"front";
}

-(void) updateWorld
{
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        //get the sprite associated with the body
        CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
        
        if(sprite.tag==SpriteStateRemove) {
            CCLOG(@"REMOVED A SPRITE FROM OUTSIDE BOUNDARY");
            if ([sprite isKindOfClass:[WizardCat class]]) {
                [wizardCats removeChild:sprite cleanup:YES];
            } else if ([sprite isKindOfClass:[Cat class]]) {
                [basicCats removeChild:sprite  cleanup:YES];
            } else if ([sprite isKindOfClass:[Bullet class]]){
                [bullets removeChild:sprite cleanup:YES];
            }
            world->DestroyBody(body);
            continue;
        }
        
        if (![sprite isKindOfClass:[Bullet class]]){
            body->SetLinearVelocity(0.97f*body->GetLinearVelocity());
            body->SetAngularVelocity(0);
        }
        
        if (sprite != NULL && sprite.tag==SpriteStateHit)
        {
            if ([sprite isKindOfClass:[Cat class]])
            {
                //TODO: Put collision sound here
                //CCLOG(@"IS CAT");
                if( ((Cat*)sprite).health==1 )
                {
                    score += ((Cat*)sprite).points;
                    if ([sprite isKindOfClass:[WizardCat class]]) {
                      [wizardCats removeChild:sprite cleanup:YES];
                    } else {
                        [basicCats removeChild:sprite  cleanup:YES];
                    }
                    world->DestroyBody(body);
                    [self createSmallExplosionAt:sprite.position];
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
                    ((Dog*)sprite).health--;
                    [self createExplosionAt:sprite.position];
                    [self removeChild:sprite cleanup:YES];
                    world->DestroyBody(body);
                    //[self endGame];
                    [KKInput sharedInput].userInteractionEnabled = NO;
                    [self performSelector:@selector(endGame) withObject:nil afterDelay:1.2f];
                    return;
                }
                else
                {
                    
                    [self beginInvincibility];
                    ((Dog*)sprite).health--;
                    sprite.tag = SpriteStateInvincible;
                    [self performSelector:@selector(endInvincibility) withObject:nil afterDelay:INVINCIBILITY];
                    return;

                }
                dogBody->SetLinearVelocity(b2Vec2(0.1f,0.1f));
            }
            else
            {
                [bullets removeChild:sprite cleanup:YES];
                world->DestroyBody(body);
            }
            sprite.tag = SpriteStateNormal;
        }
        else if (sprite != NULL)
        {
            // update the sprite's position to where their physics bodies are
        
            sprite.position = [self toPixels:body->GetPosition()];
            
            
        }
    }
    
 }

-(void) beginInvincibility
{
    dogSprite.color = ccGRAY;
   // dogBody->SetActive(NO);
    dogSprite.tag = SpriteStateInvincible;
}

-(void) endInvincibility
{
    dogSprite.color= ccWHITE;
  //  dogBody->SetActive(YES);
    dogSprite.tag = SpriteStateNormal;
}

-(void) stopTakingKKInput
{
    // This is a hack that prevents KKInput from swallowing every fuckign touch.
    // God I hate this documentation.
    KKInput* input = [KKInput sharedInput];
    
    input.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGestureRecognizer;
    tapGestureRecognizer = input.tapGestureRecognizer;
    tapGestureRecognizer.cancelsTouchesInView = NO;
}

-(void) endGame{
    
    // This is a hack that prevents KKInput from swallowing every fuckign touch.
    // God I hate this documentation.
    [self stopTakingKKInput];
     [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.7f  scene:((CCScene*)[[GameOverLayer alloc] init]) ]];
}

//Create the bullets, add them to the list of bullets so they can be referred to later
- (void)createBullets:(CGPoint)location
{
   
    Bullet *bulletSprite = [[Bullet alloc] initWithBulletImage];
    bulletSprite.position = dogSprite.position;
    [bullets addChild:bulletSprite z:9];
    //[bullets addObject:bulletSprite];
    //NSValue *value = [NSValue valueWithCGPoint:ccpSub(location, dogSprite.position)];
    //[bulletsLocations addObject:value];
 
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
    
    //[bullets addObject:[NSValue valueWithPointer:bullet]];
    CGPoint translation = ccpSub(location, dogSprite.position);
    b2Vec2 direction = b2Vec2( translation.x, translation.y);
    direction.Normalize();
    bullet->SetLinearVelocity( BULLET_SPEED*direction ); 
    bullet->SetActive(true);
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew.wav"];
    
}




/*
// TODO:Currently KKInput swallows up all touch inputs. Find out how to get around this
// Also move this menu to the top of screen rather than middle
-(void)setUpMenu
{
    CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"ship.png"
                                                         selectedImage: @"button.png"
                                                                target:self
                                                              selector:@selector(handleMenuPress:)];
    CCMenuItem *item = [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(handleMenuPress:)];
    
    NSString *scoreString = [NSString stringWithFormat:@"Score: %d",score];
    scoreItem = [CCMenuItemFont itemFromString:scoreString target:self selector:@selector(handleMenuPress:)];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    int width = (int)screenSize.width;
    int height = (int)screenSize.height;
       
    // Create a menu and add your menu items to it
    menu = [CCMenu menuWithItems:menuItem1, item, scoreItem,nil];
    menu.isTouchEnabled = YES;
   
    menu.position = ccp(width/2,height- scoreItem.rect.size.height/3*2);
    // Arrange the menu items Horizontally
    [menu alignItemsHorizontally];
    
    // add the menu to your scene
    [self addChild:menu];
}
*/


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


-(void) enableBox2dDebugDrawing
{
	// Using John Wordsworth's Box2DDebugLayer class now
	// The advantage is that it draws the debug information over the normal cocos2d graphics,
	// so you'll still see the textures of each object.
	const BOOL useBox2DDebugLayer = YES;
    
	
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;
    
	UInt32 debugDrawFlags = 0;
	debugDrawFlags += b2Draw::e_shapeBit;
	debugDrawFlags += b2Draw::e_jointBit;
	//debugDrawFlags += b2Draw::e_aabbBit;
	//debugDrawFlags += b2Draw::e_pairBit;
	//debugDrawFlags += b2Draw::e_centerOfMassBit;
    
	if (useBox2DDebugLayer)
	{
		Box2DDebugLayer* debugLayer = [Box2DDebugLayer debugLayerWithWorld:world
																  ptmRatio:PTM_RATIO
																	 flags:debugDrawFlags];
		[self addChild:debugLayer z:100];
	}
	else
	{
		GLESDebugDraw* debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
		if (debugDraw)
		{
			debugDraw->SetFlags(debugDrawFlags);
			world->SetDebugDraw(debugDraw);
            }
	}
}

@end

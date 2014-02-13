/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */
#include <stdlib.h>

#import "GameLayer.h"

#import "cocos2d.h"
#import "Box2DDebugLayer.h"

#import "Bullet.h"
#import "Cat.h"
#import "Dog.h"
#import "GameState.h"
#import "GameOverLayer.h"
#import "HUDLayer.h"
#import "SimpleAudioEngine.h"
#import "Item.h"

#define MAX_SPEED 15.0f
#define BOARD_LENGTH 1024
#define BULLET_SPEED 15.0f
#define INVINCIBILITY 2.0f
#define MAX_CATS 30

const float PTM_RATIO = 32.0f;


// These things probably don't have to be here?
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

/*
 Inits with HUDLayer added as a child (better way is for scene to be used, but for some reason it doesn't work TODO).
 */
- (id)initWithHUD:(HUDLayer *)hudLayer
{
    self = [super init];
    if (self) {
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        // Putting a background in.
        //glClearColor(.210f, .210f, .299f, 1.0f);
        
        // Initialize some variables.
        score = 0;
        elapsedTime = 0;
        numberOfCats = 0;
        hasLokitty = NO;
        hasBiggerBullets = NO;
        isDerped = NO;
        isAbnormalState = NO;
        
        // Initialize the world with its resources.
        [self initHud: hudLayer];
        [self initBox2dWorld];
        [self initSpriteSheets];
        [self initSoundsAndMusic];
        [self initBackground];
        
        // Reset the GameState (which includes typesofcatskilled)
        [[GameState sharedInstance] newGame];
		
        // Initialize the Box2d body and CCSprite of the dog.
        [self initDog];
		
		// Initialize KKInput.
        // (TODO: Maybe better to replace this with plain Cocos2d touches?)
		KKInput* input = [KKInput sharedInput];
        input.multipleTouchEnabled = YES;
		input.gestureTapEnabled = input.gesturesAvailable;
		input.gestureLongPressEnabled = input.gesturesAvailable;
		input.gesturePanEnabled = input.gesturesAvailable;
        self.isTouchEnabled = YES;
        
        [self scheduleUpdate];
        
        // Have camera follow the dog around the board.
        // This places the dog in the center.
        CGRect rect = CGRectMake(0, 0, BOARD_LENGTH, BOARD_LENGTH);
        [self runAction:[CCFollow actionWithTarget:dogSprite worldBoundary:rect]];
        
        // These are debugging tools.
        // [self enableBox2dDebugDrawing];
        // [[CCDirector sharedDirector] setDisplayFPS:YES];

        // Populate the game with cats every .5 seconds.
        [self schedule:@selector(populateWithCats) interval:.5f repeat:kCCRepeatForever delay:0.01f];

    }

	return self;
}

// This creates the repeating sky background.
-(void) initBackground
{
    // Makes texture tiled background
    
    CCSprite *spback = [(CCSprite*)[CCSprite alloc] init];
    [self addChild:spback z:-10];
    
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"sky.png"];
    ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [texture setTexParameters:&params];
    CGRect r = CGRectMake(0,0,BOARD_LENGTH*2, BOARD_LENGTH*2);
    CCSprite *bg = [[CCSprite alloc] initWithTexture:texture rect:r];
    //[self addChild:bg z:-10];
    
    [spback addChild:bg];
 
}

-(void) initSoundsAndMusic
{
    SimpleAudioEngine *engine = [SimpleAudioEngine sharedEngine];
    //CCLOG(@"muteSound: %s",[GameState sharedInstance].muteSound?"true":"false");
    
    [engine preloadBackgroundMusic:@"StarshipThorgi2.wav"];
    [engine preloadBackgroundMusic:@"PeppyThorgi.mp3"];
    [engine preloadBackgroundMusic:@"nyancat.mp3"];
    [engine playBackgroundMusic:@"PeppyThorgi.mp3" loop:YES];
    
    if ([GameState sharedInstance].muteMusic) {
        [engine pauseBackgroundMusic];
    }
    if ([GameState sharedInstance].muteSound) {
        [engine setEffectsVolume:0.0f];
    } else {
        [engine setEffectsVolume:1.0f];
    }
    [engine setBackgroundMusicVolume:0.5f];
    
    for (int i = 0; i < 8; i++) {
        NSString *sound = [NSString stringWithFormat:@"pop%d.aif", i];
        [engine preloadEffect:sound];
    }
    
    for (int i = 0; i < 9; i++) {
        NSString *sound = [NSString stringWithFormat:@"fizz%d.aif", i];
        [engine preloadEffect:sound];
    }
    
    for (int i = 0; i < 6; i++) {
        NSString *sound = [NSString stringWithFormat:@"pew%d.aif", i];
        [engine preloadEffect:sound];
    }

}

// Currently, the HUD just moves along with the dog (position is manually updated).
-(void) initHud: (HUDLayer*)hudLayer
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self->hud = hudLayer;
    self->hud.position=ccp(0,winSize.height-50);
    [self addChild:hud z:100];
}

-(void) initSpriteSheets
{
    /*
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cats.plist"];
    cats = [CCSpriteBatchNode batchNodeWithFile:@"cats.png"];
    [self addChild:cats];
     */
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"catssprite.plist"];
    cats = [CCSpriteBatchNode batchNodeWithFile:@"catssprite.png"];
    [self addChild:cats];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"thorgisprite.plist"];
    //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"lokittysprite.plist"];
    
    bullets = [CCSpriteBatchNode batchNodeWithFile:@"fire.png"];
    [self addChild:bullets];
    
    hearts = [CCSpriteBatchNode batchNodeWithFile:@"heart.png"];
    [self addChild:hearts];
    
    // [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cats.plist"];
}

// Creates the Box2d parameters on the edges.
-(void) initBox2dWorld
{
    // Construct a world object, which will hold and simulate the rigid bodies.
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    world = new b2World(gravity);
    world->SetAllowSleeping(YES);
    
    // Create an object that will check for collisions.
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    screenBorderBody = world->CreateBody(&screenBorderDef);
    
    // We use box instead of EdgeShape because otherwise cats spawn
    // at the edges of the screen and can't get into the world
    // but are still visible.
    CGSize winSize = [CCDirector sharedDirector].winSize;
    //b2EdgeShape screenBorderShape;  //This is line.
    b2PolygonShape box; //This is box.
    box.SetAsBox(winSize.width/2.0f/PTM_RATIO,
                 winSize.height/2.0f/PTM_RATIO);
    
    
    // Vertices must be in counter-clockwise order in b2Vec2.
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

// Create b2Body and ccSprite of dog.
-(void) initDog
{
    CGPoint center = ccp(BOARD_LENGTH/2.0f, BOARD_LENGTH/2.0f);
    
    // Add dog.
    dogSprite = [[Dog alloc] initWithDogImage];
    dogSprite.position = center;
    [self addChild:dogSprite z:0];
    // CCLOG(@"dogPos : %3.0f, %3.0f", dogSprite.position.x, dogSprite.position.y);
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody; 
    bodyDef.position.Set(dogSprite.position.y/PTM_RATIO, dogSprite.position.x/PTM_RATIO);
    
    bodyDef.userData = (__bridge void*) dogSprite;
    dogBody = world->CreateBody(&bodyDef);
    
    b2FixtureDef boxDef;
    
    b2PolygonShape box; // Make bounding box slightly smaller than dog image
    box.SetAsBox(.95*(dogSprite.contentSize.width/2.0f)/PTM_RATIO,
                 .9*(dogSprite.contentSize.height/2.0f)/PTM_RATIO);
    //contentSize is used to determine the dimensions of the sprite
    boxDef.shape = &box;
    
    boxDef.density = 100.0f;
    boxDef.friction = 100.0f;
    boxDef.restitution = 0.1f;
    dogBody->CreateFixture(&boxDef);
    dogBody->SetFixedRotation(YES);
}

// This handles the probability of spawning
// and the picking of random position of the cat.
-(void) populateWithCats
{
    // 30% chance to spawn a cat)
    if ((arc4random()%100) > min(100, 30 + score/2))
        return;
    CCDirector* director = [CCDirector sharedDirector];
	CGSize screenSize = director.screenSize;
    
    // Use this one once big board is implemented.
    int width = BOARD_LENGTH*2;
    int height = BOARD_LENGTH*2;
    float ratio = (1.0f*BOARD_LENGTH)/(1.0f*screenSize.width);
    CGPoint dogPos = ccp(dogSprite.boundingBoxCenter.x * ratio, dogSprite.boundingBoxCenter.y * ratio);
    int x = arc4random()%width;
    int y = arc4random()%height;
    
    int i = 0;
    // Makes sure that the cat spawns not too far & not too close to the dog.
    float distance = fabsf(hypotf(x - dogPos.x, y - dogPos.y));
    while (distance <= 400 || distance >= 700) {
        //CCLOG(@"in for loop");
        x = arc4random()%width;
        y = arc4random()%height;
        distance = hypotf(x - dogPos.x, y - dogPos.y);
        i++;
    }
    // CCLOG(@"WAS IN WHILE LOOP FOR: %d", i);
    
    CGPoint p = ccp(x,y);
    //if (numberOfCats < 1 ) //Uncomment later. This creates 1 cat only
    [self createCat:@"cat.png" atPosition:p rotation:0.0f isStatic:NO];
}

// Create b2Body and ccSprite of cat.
// Also picks the type of cat.
- (void)createCat:(NSString*)imageName
          atPosition:(CGPoint)position
            rotation:(CGFloat)rotation
            isStatic:(BOOL)isStatic
{
    Cat *sprite;
    int random = arc4random();
    
  /*  if(true) {
        sprite =[[MineCat alloc] initWithAnimatedCat];
      //  CCLOG(@"Derp cat spawned.");
    } else
  */
    if (!hasLokitty &&
        ((score!=0 && score% 50 == 0) || (score >= 55 && arc4random()%100 <3))
        ) {
        CCLOG(@"CREATED LOKITTY");
        sprite = [[Lokitty alloc] initWithAnimatedCat];
        hasLokitty = YES;
    } else if (score >= 70 && arc4random()%100 < 20) {
        sprite =[[DerpCat alloc] initWithAnimatedCat];
        CCLOG(@"Derp cat spawned.");
    } else if (score >= 45 && arc4random()%100 < 20) {
        sprite =[[MineCat alloc] initWithAnimatedCat];
        CCLOG(@"Mine cat spawned.");
    } else if (score >= 30 && arc4random()%100 < 30) {
        sprite = [[NyanCat alloc] initWithAnimatedNyanCat];
        CCLOG(@"Nyancat spawned.");
    } else if (score >= 5  && arc4random()%10 < 4 ) {
        sprite =[[WizardCat alloc] initWithAnimatedCat];
        CCLOG(@"Wizard cat spawned.");
    } else {
   //Create the sprite.
        if (score > 15 && random%10 >= 3 && cats.children.count <= score%50 * 30) {
          sprite = [[DashCat alloc] initWithAnimatedCat];
          CCLOG(@"Dash cat spawned.");
        } else {
          CCLOG(@"Normal cat spawned.");
          sprite =[[Cat alloc] initWithAnimatedCat];
        }
    }
    [cats addChild:sprite z:1];
    numberOfCats++;
    

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
}

// I think this is unused.
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

// This is used when cats die and explode.
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

// This is used when the dog has an effect (like Nyan or Loki).
-(void) createRainbowExplosionAtDog
{
    CCParticleExplosion* explosion = [[CCParticleExplosion alloc] initWithTotalParticles:10];
#ifndef KK_ARC_ENABLED
	[explosion autorelease];
#endif
	explosion.autoRemoveOnFinish = YES;
	explosion.blendAdditive = YES;
	explosion.position =dogSprite.position;
    explosion.life = 0.2f;
    explosion.lifeVar = 1.0f;
    ccColor4F color = ccc4f(0.5f, .5f, .5f, 1);
    explosion.startColor = color;
    //explosion.totalParticles = 750;
    explosion.startColorVar = ccc4f(0.5f, .5f, .5f, 0);
    explosion.startSize = 30;
    explosion.startSizeVar = 10;
    explosion.endSize = 30;
    explosion.endSizeVar = 0;
    explosion.angle = 90;
    explosion.angleVar =360;
    
    explosion.speed = 50;
    explosion.speedVar = 30;
    explosion.radialAccel = -60;
    explosion.tangentialAccel = 15;
    [self addChild:explosion];

}

// This is a helper method to get the screen position because the camera is
// following junk. I THINK. NOT SURE.
-(CGPoint) getScreenPosition:(CGPoint)point
{
    point.x -= self.position.x;
    point.y -= self.position.y;
    return point;
}

// Handles swipes and taps. Taps create bullets, swipes move dog.
-(void) gestureRecognition
{
	KKInput* input = [KKInput sharedInput];
    //CCLOG(@"detected touch on gamelayer");
    
    if ([input isAnyTouchOnNode:hud touchPhase:KKTouchPhaseBegan])
    {
        CCLOG(@"Pressed menu!!!!");
         [self stopTakingKKInput];
        return;
    }
    
    // Create bullet on tap.
	if (input.gestureTapRecognizedThisFrame)
	{
        CGPoint point = [self getScreenPosition:input.gestureTapLocation];
        [self createBullets:point];
	}
	
    // Move dog on tap.
	if (input.gesturePanBegan )
	{
        float speed = pow(input.gesturePanVelocity.x, 2) + pow(input.gesturePanVelocity.y, 2);
        speed = pow(speed, .5);
        
        CGPoint pan = [self getScreenPosition:input.gesturePanLocation];
        CGPoint eventualStop = pan;
        eventualStop.x = .90 * (pan.x - dogSprite.position.x);
        eventualStop.y = .90 * (pan.y - dogSprite.position.y);
        b2Vec2 vector = b2Vec2( eventualStop.x, eventualStop.y);
        vector.Normalize();
        vector *= (.5 * speed + .5 * 10);
        
        dogBody->SetLinearVelocity( vector);
        dogBody->SetLinearDamping(3.0f);
        
        if (isDerped) {
            dogBody->SetLinearVelocity(-1 * vector);
        }
        [dogSprite setMoveDirection:[self getDirectionFromVelocity:vector]];
    }
}

// This updates b2bodies, moves cats, and moves HUD.
-(void) update:(ccTime)delta
{
    elapsedTime += delta;
	
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

// This moves HUD so that it always stays on top of screen. HACK.
-(void) updateHUD
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    hud.position = [self getScreenPosition:ccp(0,winSize.height-40)];
    [hud setScore:score];
    NSNumber *coinCount = [MGWU objectForKey:@"coinCount"];
    int gold = [coinCount intValue];
    [hud setGold:gold];
    [hud setLives:dogSprite.health];
}

// This moves the cats. Dashcats and LokitCat are handled differently.
-(void) moveCats
{
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
        if ([sprite isKindOfClass:[Cat class]]){
            Cat* cat = (Cat*)sprite;
            b2Vec2 velocity = b2Vec2(dogSprite.boundingBoxCenter.x-sprite.boundingBoxCenter.x,dogSprite.boundingBoxCenter.y- sprite.boundingBoxCenter.y);
            velocity.Normalize();
            
            if ([cat isKindOfClass:[DashCat class]] || [cat isKindOfClass:[NyanCat class]]){
                DashCat *dashCat = (DashCat *)cat;
                if (dashCat.velocity.Length() == 0 && dashCat.speed != 0) { // not moving but about to dash
                    dashCat.velocity = velocity;
                } else {
                    velocity = dashCat.velocity;
                }
            }
            
            if ([cat isKindOfClass:[Lokitty class]]) {
                Lokitty *lokitty = (Lokitty *)cat;
                
                // This makes Lokitty go towards a randomish path hopefully
                int randomDistance = arc4random() % 2 ? 1 : -1;
                randomDistance *= arc4random() % 50;
                int randomDistance2 = arc4random() % 2 ? 1 : -1;
                randomDistance *= arc4random() % 50;
                 velocity = b2Vec2(dogSprite.boundingBoxCenter.x-sprite.boundingBoxCenter.x + randomDistance,dogSprite.boundingBoxCenter.y- sprite.boundingBoxCenter.y+ randomDistance2);
                velocity.Normalize();
                                
                if (lokitty.velocity.Length() == 0 && lokitty.speed != 0) { // not moving but about to dash
                    lokitty.velocity = velocity;
                } else {
                    velocity = lokitty.velocity;
                }
            }
            
            [cat setMoveDirection:[self getDirectionFromVelocity:velocity]];
            body->SetLinearVelocity(((Cat*)sprite).speed*velocity);
            body->SetAngularVelocity(0);
        }
    }
}

// Helper method that gets angle from velocity. I think this is unused?
-(CGFloat) getAngleFromVelocity: (b2Vec2)velocity
{
    CGFloat angle = atan2(velocity.y,velocity.x)*180.0f/M_PI;
    if (angle < 0) angle+=360;
    return angle;
}

// Gets 4 compass directions from velocity.
-(NSString*) getDirectionFromVelocity: (b2Vec2)velocity
{
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

// This handles every enemies' bullets.
-(void) shootBulletAtDog:(CGPoint)location isLoki:(Boolean)isLoki sprite:(CCSprite*)sprite
{
    
    Bullet *bulletSprite;
    if ([sprite isKindOfClass:[DerpCat class]] ){
       // CCLOG(@"Created derp bullet for sprite %@", sprite);
       bulletSprite = [[DerpBullet alloc] initWithBulletImage];
    } else if ([sprite isKindOfClass:[MineCat class]] ){
        bulletSprite = [[MineBullet alloc] initWithBulletImage];
    } else {
          bulletSprite = [[WizardBullet alloc] initWithBulletImage];
    }
    bulletSprite.position = location;
    //bulletSprite.color = ccBLUE;//ccc3(1.0f,0,1.0f); //purple
    if (isLoki) bulletSprite.color = ccGREEN;
    bulletSprite.tag = SpriteStateEnemyBullet;
    [bullets addChild:bulletSprite z:5];
    
    b2BodyDef bulletBodyDef;
    bulletBodyDef.type = b2_dynamicBody;
    bulletBodyDef.bullet = true; //this tells Box2D to check for collisions more often - sets "bullet" mode on
    bulletBodyDef.position.Set(location.x/PTM_RATIO,location.y/PTM_RATIO);
    bulletBodyDef.userData = (__bridge void*)bulletSprite;
    b2Body *bullet = world->CreateBody(&bulletBodyDef);
    bullet->SetActive(false); //an inactive body does not collide with other bodies
    
    b2CircleShape circle;
    circle.m_radius = bulletSprite.textureRect.size.width/2.0f/PTM_RATIO; //you can figure the dimensions out by looking at flyingpenguin.png in image editing software
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.8f;
    ballShapeDef.restitution = 0.0f; //set the "bounciness" of a body (0 = no bounce, 1 = complete (elastic) bounce)
    ballShapeDef.friction = 0.99f;
    ballShapeDef.isSensor = true;
    //try changing these and see what happens!
    bullet->CreateFixture(&ballShapeDef);
    
    //[bullets addObject:[NSValue valueWithPointer:bullet]];
    CGPoint translation = ccpSub(dogSprite.position, location);
    b2Vec2 direction = b2Vec2( translation.x, translation.y);
    direction.Normalize();
    bullet->SetLinearVelocity( BULLET_SPEED/ 4 * direction );
    bullet->SetActive(true);
    
    // Make mines not move
    if ([sprite isKindOfClass:[MineCat class]] ){
        bullet->SetLinearVelocity(0 * direction);
    }
    
    //[[SimpleAudioEngine sharedEngine] playEffect:@"pew.wav"];
    
    NSString *sound = [NSString stringWithFormat:@"pew%d.aif", arc4random()%6];
    [[SimpleAudioEngine sharedEngine] playEffect:sound pitch:1.0f pan:1.0f gain:0.95f];

}

// This handles removal of b2bodies and ccsprites.
// This also handles different sprite states such as SpriteStateNyan and SpriteStateLoki.
// This is kind of a clusterfudge of junk, which should prolly be later refactored.
-(void) updateWorld
{
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        //get the sprite associated with the body
        CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
        switch(sprite.tag) {
            case SpriteStateRemove: 
                //CCLOG(@"REMOVED A SPRITE FROM OUTSIDE BOUNDARY");
                if ([sprite isKindOfClass:[Lokitty class]]) { //Currently a hack, should be in cats.png bleh
                    hasLokitty = NO;
                }
                
                if ([sprite isKindOfClass:[Cat class]]) {
                    [cats removeChild:sprite cleanup:YES];
                } else if ([sprite isKindOfClass:[Bullet class]]){
                    [bullets removeChild:sprite cleanup:YES];
                } else if ([sprite isKindOfClass:[Heart class]]){
                    [hearts removeChild:sprite cleanup:YES];
                } else {
                    [self removeChild:sprite cleanup:YES];
                }
                world->DestroyBody(body);
                continue;
                break;
            
            case SpriteStateNyan:
               // if (!isAbnormalState) {
                    isAbnormalState = YES;
                    CCLOG(@"Started rainbows");
                    [self unschedule:@selector(createRainbowExplosionAtDog)];
                
                    [self schedule:@selector(createRainbowExplosionAtDog) interval:0.2f repeat:46 delay:0.0f];
                    [self runNyanMusic];
                    sprite.tag = SpriteStateInvincible;
                    sprite.color = ccYELLOW;
                    [self unschedule:@selector(endInvincibility)];
                    [self scheduleOnce:@selector(endInvincibility) delay:10.1f];
             //   }
                break;
                
            case SpriteStateRupee:
              //  if (!isAbnormalState) {
                    CCLOG(@"Started rupee");
                    isAbnormalState = YES;
                    hasBiggerBullets = YES;
                    [self unschedule:@selector(createRainbowExplosionAtDog)];
                    [self schedule:@selector(createRainbowExplosionAtDog) interval:0.2f repeat:47 delay:0.0f];
                    [self runLokiMusic];
                    sprite.tag = SpriteStateInvincible;
                    sprite.color = ccGREEN;
                    [self unschedule:@selector(endInvincibility)];
                    [self scheduleOnce:@selector(endInvincibility) delay:10.1f];
              //  }
                break;
                
            case SpriteStateDerp:
                CCLOG(@"Started derp %@", isDerped? @"YES":@"NO");
                if (!isAbnormalState) {
                    isAbnormalState = YES;
                    sprite.color = ccBLUE;
                    isDerped = YES;
                    [self scheduleOnce:@selector(endDerp) delay:13.0f];
                    sprite.tag = SpriteStateNormal;
                }
                break;
        }
        
            // Bodies that aren't bullets slow down as they reach their destination
            if (![sprite isKindOfClass:[Bullet class]]){
                body->SetLinearVelocity(0.97f*body->GetLinearVelocity());
                body->SetAngularVelocity(0);
            }
            
            // Have dog sprite stop if near 0 velocity
            if ([sprite isKindOfClass:[Dog class]]) {
                float distance = pow(pow(body->GetLinearVelocity().x,2) + pow(body->GetLinearVelocity().y,2),.5);
                if (distance < 1.25f) {
                    [dogSprite stopAction];
                }
            }
            
            // Have wizard shoot if they're supposed to shoot.
            if ([sprite isKindOfClass:[WizardCat class]]) {
                if (((WizardCat *)sprite).countdown == 0) {
                    [self shootBulletAtDog:sprite.position isLoki:[sprite isKindOfClass:[Lokitty class]] sprite:sprite];
                    [(WizardCat *)sprite resetCountDown];
                    
                }
            }
            
            // Handles hits.
            if (sprite != NULL && sprite.tag==SpriteStateHit)
            {
                [self handleHits:body];
            }
            else if (sprite != NULL)
            {
                // Update the sprite's position to where their physics bodies are.
                sprite.position = [self toPixels:body->GetPosition()];
            }
        }
}

// Runs Starship Thorgi when in Green Loki State.
-(void) endDerp {
    
    //Maybe don't change velocity here. just do a boolean
    //dogBody->SetLinearVelocity( -1*dogBody->GetLinearVelocity());
    isDerped = NO;
    dogSprite.color = ccWHITE;
    dogSprite.tag = SpriteStateNormal;
    hasBiggerBullets = NO;
    isAbnormalState = NO;
    CCLOG(@"ended DERP");
   
}


// Runs Starship Thorgi when in Green Loki State.
-(void) runLokiMusic {
    SimpleAudioEngine *audio = [SimpleAudioEngine sharedEngine];
    if ([audio isBackgroundMusicPlaying]) {
        [audio stopBackgroundMusic];
        [audio playBackgroundMusic:@"StarshipThorgi2.wav" loop:YES];
       // [audio playBackgroundMusic:@"StarshipThorgi.wav" loop:YES];
        [self unschedule:@selector(runNormalMusic)];
        [self scheduleOnce:@selector(runNormalMusic) delay:10.0f];
    }
}

// Runs Nyancat music.
-(void) runNyanMusic {
    SimpleAudioEngine *audio = [SimpleAudioEngine sharedEngine];
    if ([audio isBackgroundMusicPlaying]) {
    [audio stopBackgroundMusic];
    [audio playBackgroundMusic:@"nyancat.mp3" loop:YES];
           [self unschedule:@selector(runNormalMusic)];
    [self scheduleOnce:@selector(runNormalMusic) delay:10.0f];
    }
    
}

// Runs normal pepy thorgi music.
-(void) runNormalMusic {
    SimpleAudioEngine *audio = [SimpleAudioEngine sharedEngine];
    if ([audio isBackgroundMusicPlaying]) {
        [audio stopBackgroundMusic];
        [audio playBackgroundMusic:@"PeppyThorgi.mp3" loop:YES];
    }
}

// Handles every sprite's hits. Cats' health decrease and dog's health decreases.
-(void) handleHits: (b2Body *)body
{
     CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
    if ([sprite isKindOfClass:[Cat class]])
    {
        if( ((Cat*)sprite).health==1 )
        {
            [self killCat:body];
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

// Increments game state as well.
-(void) killCat:(b2Body *)body
{
    CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
    score += ((Cat*)sprite).points;
    //Play dying sound.
    NSString *sound = [NSString stringWithFormat:@"fizz%d.aif", arc4random()%9];
    [[SimpleAudioEngine sharedEngine] playEffect:sound pitch:1.0f pan:1.0f gain:0.25f];
    
    if ([sprite isKindOfClass:[Lokitty class]]) {
       hasLokitty = NO;
    } else if ([sprite isKindOfClass:[WizardCat class]]) {
        [GameState sharedInstance].wizardCatsKilledThisGame++;
    } else if ([sprite isKindOfClass:[DashCat class]]){
         [GameState sharedInstance].dashCatsKilledThisGame++;
    } else if ([sprite isKindOfClass:[NyanCat class]]) {
        [GameState sharedInstance].nyanCatsKilledThisGame++;
    } else {
        [GameState sharedInstance].basicCatsKilledThisGame++;
    }
    [cats removeChild:sprite cleanup:YES];
    
    [[GameState sharedInstance] save];
    world->DestroyBody(body);
    [self createSmallExplosionAt:sprite.position];
    [self createItem:sprite.position sprite:sprite];
}

// Creates an item drop based on probability and type of cat sprite.
-(void) createItem:(CGPoint)position sprite:(CCSprite *)sprite
{
    Item *item;
    if ([sprite isKindOfClass:[NyanCat class]] ||
        [sprite isKindOfClass:[Lokitty class]] ||
        arc4random()%100 < 20) {//max(5,10-score/50) ) {
      /*
       // Good for testing lokitty and poptart
        if (YES) {
            item = arc4random() %2 == 0? [[Rupee alloc] init] : [[PopTart alloc] init];
            item.position = position;
            [self addChild:item];
        }
       else
        */
         if ([sprite isKindOfClass:[Lokitty class]]) {
            item = [[Rupee alloc] init];
            item.position = position;
            [self addChild:item];
        }
        else if ([sprite isKindOfClass:[NyanCat class]]) {
            if ( arc4random()%2 == 0) {
            item = [[PopTart alloc]init];
            item.position = position;
            [self addChild:item];
            } else {
                return;
            }
        }
        else if (arc4random()%3 == 0){
            item = [[Heart alloc]init];
            item.position = position;
            [hearts addChild:item];
        } else {
            item = [[Coin alloc]init];
            item.position = position;
            [self addChild:item];
        }
        
        //add body
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(position.x/PTM_RATIO,position.y/PTM_RATIO);
        bodyDef.userData = (__bridge void*)item;
        b2Body *itemBody = world->CreateBody(&bodyDef);
        //itemBody->SetActive(false); //an inactive body does not collide with other bodies
        
        // Create the bounding box shape.
        b2PolygonShape box;
        box.SetAsBox(item.boundingBox.size.width/2.0f/PTM_RATIO,
                     item.boundingBox.size.height/2.0f/PTM_RATIO);
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &box;
        ballShapeDef.density = 0.8f;
        ballShapeDef.restitution = 0.0f; //set the "bounciness" of a body (0 = no bounce, 1 = complete (elastic) bounce)
        ballShapeDef.friction = 0.99f;
        ballShapeDef.isSensor = true;
        //try changing these and see what happens!
        itemBody->CreateFixture(&ballShapeDef);
    }
}

// Begin invincibility (that happens after dog is hit).
-(void) beginInvincibility
{
    dogSprite.color = ccGRAY;
    dogSprite.tag = SpriteStateInvincible;
    isDerped = NO;
}

// Ends all types of invincibility.
-(void) endInvincibility
{
    CCLOG(@"ended invincibility");
    dogSprite.color= ccWHITE;
    dogSprite.tag = SpriteStateNormal;
    hasBiggerBullets = NO;
    isAbnormalState = NO;
    isDerped = NO;
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

// Stops music and replaces scene
-(void) endGame{
    [self stopTakingKKInput];
     [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
     [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.7f  scene:((CCScene*)[[GameOverLayer alloc] initWithScore:score]) ]];
}

//Create the bullets, add them to the list of bullets so they can be referred to later
- (void)createBullets:(CGPoint)location 
{
    NSString *sound = [NSString stringWithFormat:@"pop%d.aif", arc4random()%8];
    [[SimpleAudioEngine sharedEngine] playEffect:sound pitch:1.0f pan:1.0f gain:0.8f];
    
    Bullet *bulletSprite = [[Bullet alloc] initWithBulletImage];
    bulletSprite.position = dogSprite.position;
    bulletSprite.color = ccYELLOW;
    bulletSprite.scale = hasBiggerBullets? 5.0f : 1.0f;
    //CCLOG(@"Has bigger bullets? %f", bulletSprite.scale);
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
    circle.m_radius = bulletSprite.textureRect.size.width/2.0f/PTM_RATIO; //you can figure the dimensions out by looking at flyingpenguin.png in image editing software
    
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
}

// Convenience method to convert a b2Vec2 to a CGPoint.
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

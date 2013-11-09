/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "ContactListener.h"
#import "cocos2d.h"
#import "GameLayer.h"

#import "Bullet.h"
#import "Cat.h"
#import "Dog.h"


void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
    
    // If wall
    if (spriteA == NULL && spriteB != NULL && ![spriteB isKindOfClass:[Dog class]]) {
        //remove Sprite B
        spriteB.tag=SpriteStateRemove;
        return;
    } else if (spriteA != NULL && spriteB == NULL && ![spriteA isKindOfClass:[Dog class]]) {
        spriteA.tag=SpriteStateRemove;
        return;
    }
    
    // If shooting at dog
    if (([spriteA isKindOfClass:[Dog class]] && [spriteB isKindOfClass:[Bullet class]]) ||
        ([spriteB isKindOfClass:[Dog class]] && [spriteA isKindOfClass:[Bullet class]])) {
        if (spriteA.tag == SpriteStateEnemyBullet || spriteB.tag == SpriteStateEnemyBullet) {
            ((__bridge CCSprite*) contact->GetFixtureA()->GetBody()->GetUserData()).tag=SpriteStateHit;
            ((__bridge CCSprite*) contact->GetFixtureB()->GetBody()->GetUserData()).tag=SpriteStateHit;
            spriteA.color = ccRED;
            spriteB.color = ccRED;
        }
    }
    
    // If shooting a cat.
    if (spriteA != NULL && spriteB != NULL)
	{
        if (([spriteA isKindOfClass:[Cat class]] && [spriteB isKindOfClass:[Bullet class]]) ||
            ([spriteB isKindOfClass:[Cat class]] && [spriteA isKindOfClass:[Bullet class]])) {
            if (spriteA.tag == SpriteStateEnemyBullet || spriteB.tag == SpriteStateEnemyBullet) {
                return;
            }
            
                ((__bridge CCSprite*) contact->GetFixtureA()->GetBody()->GetUserData()).tag=SpriteStateHit;
                ((__bridge CCSprite*) contact->GetFixtureB()->GetBody()->GetUserData()).tag=SpriteStateHit;
                spriteA.color = ccRED;
                spriteB.color = ccRED;
        }
        
        // When dog is invincible.
        if (spriteA.tag == SpriteStateInvincible || spriteB.tag == SpriteStateInvincible) {
            //CCLOG(@"begincontact invinc");
            return;
        }

        // When cats run into dogs.
        if (([spriteA isKindOfClass:[Cat class]] && [spriteB isKindOfClass:[Dog class]]) ) {
           // CCLOG(@"Dog hit!1");
           //  ((Dog*)spriteB).health--; 
            spriteB.color = ccGREEN;
            ((__bridge CCSprite*) contact->GetFixtureA()->GetBody()->GetUserData()).tag=SpriteStateHit;
            spriteA.color = ccRED;
             ((__bridge CCSprite*) contact->GetFixtureB()->GetBody()->GetUserData()).tag=SpriteStateHit;
        } else if (([spriteB isKindOfClass:[Cat class]] && [spriteA isKindOfClass:[Dog class]])) {
            // CCLOG(@"Dog hit!2");
           // ((Dog*)spriteA).health--;  
            spriteA.color = ccBLUE;
            ((__bridge CCSprite*) contact->GetFixtureA()->GetBody()->GetUserData()).tag=SpriteStateHit;
            spriteB.color = ccRED;
            ((__bridge CCSprite*) contact->GetFixtureB()->GetBody()->GetUserData()).tag=SpriteStateHit;
        }
        
	}
    
}

void ContactListener::EndContact(b2Contact* contact)
{
    /*
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
	
	if (spriteA != NULL && spriteB != NULL)
	{
	//	spriteA.color = ccWHITE;
	//	spriteB.color = ccWHITE;
        if (([spriteA isKindOfClass:[Cat class]] && [spriteB isKindOfClass:[Cat class]]) ) {
            contact->SetEnabled(false);
        }

	}
     */
}


void ContactListener::PreSolve(b2Contact* contact,
                               const b2Manifold* oldManifold) {
    
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	CCSprite* spriteA = (__bridge CCSprite*)bodyA->GetUserData();
	CCSprite* spriteB = (__bridge CCSprite*)bodyB->GetUserData();
    
    if (spriteA != NULL && spriteB != NULL)
	{
        //	spriteA.color = ccWHITE;
        //	spriteB.color = ccWHITE;
        if (([spriteA isKindOfClass:[Cat class]] && [spriteB isKindOfClass:[Cat class]]) )
        {
            contact->SetEnabled(false);
        }
        else if (spriteA.tag == SpriteStateInvincible || spriteB.tag == SpriteStateInvincible) {
            //CCLOG(@"presolved invincible");
            contact->SetEnabled(false);
        }
        
	}
    // If it's a wall, get rid of the sprite that isn't a wall
    //TODO: TEST THAT THIS WORKS. THAT IF SPRITE A IS NULL IT'S A WALL.
    else if (spriteA == NULL && spriteB != NULL && ![spriteB isKindOfClass:[Dog class]]) {
        //remove Sprite B
        contact->SetEnabled(false);
         spriteB.tag=SpriteStateRemove;
    } else if (spriteA != NULL && spriteB == NULL && ![spriteA isKindOfClass:[Dog class]]) {
        //remove Sprite A
        contact->SetEnabled(false);
        spriteA.tag=SpriteStateRemove;
    }
    
}

/*
void ContactListener::PostSolve(b2Contact* contact,
                                const b2ContactImpulse* impulse)
{
    bool isAEnemy = contact->GetFixtureA()->GetUserData() != NULL; //is A
    bool isBEnemy = contact->GetFixtureB()->GetUserData() != NULL;
    
   // CCLOG(@"%s  %s", isAEnemy? "true" : "false", isBEnemy? "true" : "false");
    
    if (isAEnemy || isBEnemy)
    {
        // Should the body break?
        int32 count = contact->GetManifold()->pointCount;
        //stores # of points of contact
        
        float32 maxImpulse = 0.0f;
        for (int32 i = 0; i < count; ++i)
        {
            maxImpulse = b2Max(maxImpulse, impulse->normalImpulses[i]);
            //this tests the impulse along each point of contact, and finds the maximum
        }
        
        if (maxImpulse > 1.0f)
        {
            // Flag the enemies we want to destroy later
            if (isAEnemy)
                ((__bridge CCSprite*) contact->GetFixtureA()->GetBody()->GetUserData()).tag=2;
            if (isBEnemy)
                ((__bridge CCSprite*) contact->GetFixtureB()->GetBody()->GetUserData()).tag=2;
            //we access the sprite that corresponds to the body through GetUserData() and set its tag to 2
        }
    }
}
*/
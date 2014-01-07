//
//  LocalScore.m
//  Thorgi
//
//  Created by Amy Tang on 11/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
// Simple container class for storing local scores.

#import "LocalScore.h"

@interface LocalScore (PrivateMethods)
// declare private methods here
@end

@implementation LocalScore

@synthesize score;
@synthesize username;

-(id) init
{
	self = [super init];
	if (self)
	{
		// add init code here (note: self.parent is still nil here!)
		
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(id) initWithScoreAndUsername:(int) score username:(NSString *)username {
    self = [super init];
	if (self)
	{
		self.score = score;
        self.username = username;
	}
	return self;
}

-(void) dealloc
{
	// uncomment if you're not using ARC (ahem, make that: *still* not using ARC ...)
	//[super dealloc];
	
	// if you suspect a memory leak, put a breakpoint here to see if the node gets deallocated
	NSLog(@"dealloc: %@", self);
}

#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder;
{
    [encoder encodeInt:self.score forKey:@"score"];
    [encoder encodeObject:self.username forKey:@"username"];
}

- (id)initWithCoder:(NSCoder *)decoder;
{
    if ( ![super init] )
    	return nil;
    
    score = [decoder decodeIntForKey:@"score"];
    username = [decoder decodeObjectForKey:@"username"];
    
    return self;
}



@end

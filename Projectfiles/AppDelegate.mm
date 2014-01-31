/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"
// At the top of the file
#import "GCHelper.h"
#import "LandscapeOnlyViewController.h"



@implementation AppDelegate

-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
    // At the end of applicationDidFinishLaunching, right before
    // the last line that calls runWithScene:
    [[GCHelper sharedInstance] authenticateLocalUser];
    
    navController = [[LandscapeOnlyViewController alloc] initWithRootViewController:director];
    window.rootViewController = navController;
    navController.navigationBarHidden = YES;
    [window makeKeyAndVisible];
    
    [MGWU loadMGWU:@"12QWaszxthorgi"];
    [MGWU preFacebook]; //Temporarily disables Facebook until you integrate it later
}

-(id) alternateView
{
	return nil;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

@end

//
//  LandscapeOnlyViewController.m
//  Thorgi
//
//  Created by Amy Tang on 11/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LandscapeOnlyViewController.h"

@interface LandscapeOnlyViewController (PrivateMethods)
// declare private methods here
@end

@implementation LandscapeOnlyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This is required to allow GameCenter to login in portrait mode, but only allow landscape mode for the rest of the game play/
// Arrrgg!

-(BOOL) shouldAutorotate {
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight; // or left if you prefer
}

-(NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskLandscape;
    else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [[UIDevice currentDevice] orientation] != UIInterfaceOrientationPortrait;
}

-(UIInterfaceOrientation) getCurrentOrientation {
    return [[UIDevice currentDevice] orientation];
}
@end

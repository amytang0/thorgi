//
//  StartMenuLayer.h
//  Thorgi
//
//  Created by Amy Tang on 10/12/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "kobold2d.h"

@interface StartMenuLayer : CCLayer
{
@protected
@private
}
+(id) scene;
-(void) playGame:(CCMenuItem *)sender;
- (IBAction)showMessage:(id)sender;
@end

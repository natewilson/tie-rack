//
//  TRSplashViewController.h
//  Tie Rack
//
//  Created by Nate Wilson on 10/21/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRAppDelegate.h"

@interface TRSplashViewController : UIViewController <UIGestureRecognizerDelegate>

- (void) dismiss: (UIGestureRecognizer *)recognizer;

- (void) setImage: (NSString *)fname;

- (void) moveImageToBottom;
- (void) moveImageToTop;

- (id) initWithDelegate:(TRAppDelegate *)delegate andImageNamed: (NSString *)fname;

@end

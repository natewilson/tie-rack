//
//  TRAppDelegate.m
//  Tie Rack
//
//  Created by Nate Wilson on 5/21/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
// <('o'<)

#import "TRAppDelegate.h"
#import "TRViewController.h"
#import "TRSplashViewController.h"

@implementation TRAppDelegate

TRViewController *trvc;
TRSplashViewController *adScreen;
NSInteger swapCount;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    
    // Setup the main view controller with the video preview
    trvc = [[TRViewController alloc] init];
    [[trvc view] setBackgroundColor:[UIColor clearColor]];
    
    // Now setup and show the introductory "ad"
    adScreen = [[TRSplashViewController alloc] initWithDelegate:self andImageNamed:@"HowToUse"];
    [adScreen moveImageToBottom];
    [[adScreen view] setBackgroundColor:[UIColor colorWithRed:(79./255) green:(44./255) blue:(29./255) alpha:1]];
    [adScreen setImage:@"HowToUse"];
    
    [self.window setRootViewController:adScreen];
    
    // Start counting how many times we've swapped into the app.
    swapCount = 0;
    
    // and show the app
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) goLive {
    [self.window setRootViewController:trvc];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Keep track of how many times we swap back to the app
    swapCount++;
    
    // We may change the screen we show based on the date so get an easy-to-read date string.
    NSDate *today = [[NSDate alloc] init];
    NSDateFormatter *todayStringFormatter = [[NSDateFormatter alloc]init];
    [todayStringFormatter setDateFormat:@"MM/dd"];
    NSString *dateToday = [todayStringFormatter stringFromDate:today];
    [todayStringFormatter setDateFormat:@"MM/dd/yyyy"];
    
    // First set it to a default of nil so that we won't show it if we don't need to.
    NSString *imageName = nil;
    
    if ([dateToday isEqualToString:@"10/31"]) {
        // Generic KTI reminder that can be used over and over again.  (The tie pictured is small)
        // (focus is on the Kenny profile)
        imageName = @"KTIDayAd";
        [[adScreen view] setBackgroundColor:[UIColor colorWithRed:(217./255) green:(217./255) blue:(217./255) alpha:1.0]];
        [adScreen moveImageToTop];
    } else if ([[todayStringFormatter stringFromDate:today] isEqualToString:@"10/30/2013"]) {
        imageName = @"KTIPreviewAd";
        [[adScreen view] setBackgroundColor:[UIColor colorWithRed:(217./255) green:(217./255) blue:(217./255) alpha:1.0]];
        [adScreen moveImageToTop];
    } else if (swapCount % 8 == 0) {
        // Every 10 times (when we're *not* showing a KTI ad)
        imageName = @"MobileITSolutionsAd";
        [[adScreen view] setBackgroundColor:[UIColor whiteColor]];
        [adScreen moveImageToBottom];
    }
    
    // Only show an ad if one was picked out.
    if (imageName) {
        [adScreen setImage:imageName];
        [self.window setRootViewController:adScreen];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

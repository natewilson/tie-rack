//
//  TRSplashViewController.m
//  Tie Rack
//
//  Created by Nate Wilson on 10/21/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRSplashViewController.h"

@interface TRSplashViewController ()

@end

@implementation TRSplashViewController

UIImage *myImage;
UIImageView *splash;
UITapGestureRecognizer *tapper;
TRAppDelegate *_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithDelegate: (TRAppDelegate *)delegate  andImageNamed:(NSString *)fname {
    self = [super init];
    if (self) {
        NSLog(@"init'ing new splash view controller");
        NSLog(@"Frame Height: %f", self.view.frame.size.height);
        NSLog(@"Mainscreen bounds height: %f", [[UIScreen mainScreen] bounds].size.height);
        NSLog(@"Self.view.height: %f", self.view.frame.size.height);
        _delegate = delegate;
        myImage = [UIImage imageNamed:fname];
        NSLog(@"Setting image: %@, [%d]", fname, (int)(myImage != nil));
    }
    return self;
}

- (void) setImage:(NSString *)fname {
    NSLog(@"Setting image: %@", fname);
    myImage = [UIImage imageNamed:fname];
    [splash setImage:myImage];
}

// Override to create a very basic view that matches the screen size.
- (void) loadView {
    [self setView:[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"Loading up a view with height: %f", self.view.frame.size.height);
    //[[self view] setFrame:[[UIScreen mainScreen] bounds]];
    
    // Use the width of the view frame to keep proportions equal to 320:480 but
    // still allow the overall size to grow by device.
    CGFloat imgWidth = [self.view frame].size.width;
    CGRect imgFrame = CGRectMake(0, 0, imgWidth, (imgWidth/320*480));
    
    splash = [[UIImageView alloc] initWithFrame:imgFrame];
    [splash setImage:myImage];
    [[self view] setAlpha:1.0];
    
    // Setup and configure the tapping recognizer.... be thorough.
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [tapper setNumberOfTapsRequired:1];
    [tapper setNumberOfTouchesRequired:1];
    [tapper setEnabled:YES];
    
    // Now associate the tapper recognizer with the screen.
    tapper.delegate = self;
    [self.view addGestureRecognizer:tapper];
    
    // and finally add the image (in proportion).
    [self.view addSubview:splash];
}

- (void)dismiss: (UIGestureRecognizer *)recognizer {
    NSLog(@"Received a tap");
    [_delegate goLive];
}

- (void) moveImageToBottom {
    CGRect frame = [splash frame];
    frame.origin.y = [self.view frame].size.height - frame.size.height;
    [splash setFrame:frame];
}

- (void) moveImageToTop {
    NSLog(@"Moving to top");
    CGRect frame = [splash frame];
    frame.origin.y = 0;
    NSLog(@"Current frame: %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    [splash setFrame:frame];
    CGRect vf = [self view].frame;
    NSLog(@"Current view frame: %f, %f, %f, %f", vf.origin.x, vf.origin.y, vf.size.width, vf.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

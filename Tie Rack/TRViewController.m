//
//  TRViewController.m
//  Tie Rack
//
//  Created by Rene Candelier on 5/28/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRViewController.h"
#import "TRTiesListModel.h"
#import "TRPhotoBuilder.h"
#import "TRScrollingTieRackView.h"
#import <UIKit/UIGestureRecognizer.h>

@interface TRViewController ()
// UI element stuffs:
@property (strong, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) IBOutlet UIPageControl *tieIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *tieImageView;
// holds and manages tie imagery:
@property (strong, nonatomic) TRTiesListModel *rack;
// Used for simultaneous UX:
@property (nonatomic) TRScrollingTieRackView *scrollingRackView;
@end



@implementation TRViewController

// Properties exposed externally
@synthesize captureSession;
@synthesize previewLayer;

- (IBAction)takeSnapshot:(UIButton *)sender {
    TRPhotoBuilder *photographer = [[TRPhotoBuilder alloc] init];
    [photographer captureImage:self
                       withTie:[self.rack currentTieImage]
                  andTransform:self.scrollingRackView.transform];
}

- (TRTiesListModel *) rack {
    // "lazy instantiation" pattern
    if (!_rack) _rack = [[TRTiesListModel alloc] init];
    return _rack;
}

- (void) tieWillChange {
    [self.tieIndicator setCurrentPage:[self.rack currentTieIndex]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
    }
    return self;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    self.scrollingRackView.transform = CGAffineTransformScale(self.scrollingRackView.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    self.scrollingRackView.transform = CGAffineTransformRotate(self.scrollingRackView.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add video input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (!error){
        [[self captureSession] addInput:videoIn];
    }
    
    //add video preview layer
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //starting to set up the preview layer as a view
    CGRect layerRect = [[[self view] layer] bounds];
	[[self previewLayer] setBounds:layerRect];
	[[self previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [[[self view] layer] insertSublayer:[self previewLayer] atIndex:0];
    
    // Add a scrolling rack view, setting "self" to receive notifications
    self.scrollingRackView = [[TRScrollingTieRackView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) andTieList:self.rack];
    [self.scrollingRackView addDelegate:self];
    [self.view addSubview:self.scrollingRackView];
    
    // Now setup a few gesture recognizers to handle the rotation and scaling of the ties
    UIRotationGestureRecognizer *rotater = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    UIPinchGestureRecognizer *pincher = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    rotater.delegate = self;
    pincher.delegate = self;
    [self.view addGestureRecognizer:rotater];
    [self.view addGestureRecognizer:pincher];
    
    // Now setup the tieIndicator and bring it on top of the scrolling view along with the capture button.
    [self.tieIndicator setNumberOfPages:[self.rack numberOfTies]];
    [self.tieIndicator setCurrentPage:[self.rack currentTieIndex]];
    [self.view bringSubviewToFront:self.tieIndicator];
    [self.view bringSubviewToFront:self.captureButton];
    
    //start the capture session
    [captureSession startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Utility methods
- (CGFloat) constrainFloat: (CGFloat) f byMin: (CGFloat) min andMax: (CGFloat) max {
    if (f > max) return max;
    else if (f < min) return min;
    else return f;
}

@end

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


// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";


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

// Internal variables
AVCaptureStillImageOutput *stillImageOutput;
UIView *flashView;
TRAppDelegate *_delegate;

- (void) setDelegate:(TRAppDelegate *)delegate {
    _delegate = delegate;
}

- (AVCaptureStillImageOutput *) getImageOut {
    return stillImageOutput;
}


- (IBAction)takeSnapshot:(UIButton *)sender {
    TRPhotoBuilder *photographer = [[TRPhotoBuilder alloc] init];
    [photographer captureImage:self
                       withTie:[self.rack currentTieImage]
                  andTransform:self.scrollingRackView.transform
                andTranslation:self.scrollingRackView.translation];
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
        [[self view] setFrame:[UIScreen mainScreen].bounds];
        NSLog(@"TRView height: %f", [UIScreen mainScreen].bounds.size.height);
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


- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.scrollingRackView.scrollEnabled = NO;
            [recognizer setTranslation:self.scrollingRackView.translation inView:self.view];
            break;
        case UIGestureRecognizerStateChanged:
            self.scrollingRackView.translation = [recognizer translationInView:self.view];
            break;
        case UIGestureRecognizerStateEnded:
            self.scrollingRackView.scrollEnabled = YES;
            break;
        default:
            break;
    }
    
    //CGPoint loc = [recognizer translationInView:self.scrollingRackView];
    //self.scrollingRackView.transform = CGAffineTransformTranslate(self.scrollingRackView.transform, loc.x, loc.y);
    //[recognizer setTranslation:CGPointMake(0, 0) inView:self.scrollingRackView];
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
    
    // Make a still image output  [NOTE: As of introduction on 10/19 this is NOT used for capture]
    stillImageOutput = [AVCaptureStillImageOutput new];
    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
    if ( [[self captureSession] canAddOutput:stillImageOutput] )
        [[self captureSession] addOutput:stillImageOutput];
    
    //add video preview layer
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //starting to set up the preview layer as a view
    CGRect layerRect = [[UIScreen mainScreen] bounds];
    NSLog(@"LayerRect: %f", layerRect.size.height);
    
    [[self view] setFrame:layerRect];
	[[self previewLayer] setFrame:layerRect];
	[[self previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [[[self view] layer] insertSublayer:[self previewLayer] atIndex:0];
    
    // Add a scrolling rack view, setting "self" to receive notifications
    self.scrollingRackView = [[TRScrollingTieRackView alloc] initWithFrame:[self.view frame] andTieList:self.rack];
    [self.scrollingRackView addDelegate:self];
    [self.view addSubview:self.scrollingRackView];
    
    // Now setup a few gesture recognizers to handle the rotation and scaling of the ties
    UIRotationGestureRecognizer *rotater = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    UIPinchGestureRecognizer *pincher = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panner setMinimumNumberOfTouches:2];
    rotater.delegate = self;
    pincher.delegate = self;
    panner.delegate  = self;
    [self.view addGestureRecognizer:rotater];
    [self.view addGestureRecognizer:pincher];
    [self.view addGestureRecognizer:panner];
    
    // Now setup the tieIndicator and bring it on top of the scrolling view along with the capture button.
    [self.tieIndicator setNumberOfPages:[self.rack numberOfTies]];
    [self.tieIndicator setCurrentPage:[self.rack currentTieIndex]];
    [self.view bringSubviewToFront:self.tieIndicator];
    [self.view bringSubviewToFront:self.captureButton];
    
    //start the capture session
    [captureSession startRunning];
    
}

- (CGSize) getVideoPreviewLayerSize
{
    return [self.previewLayer bounds].size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext) ) {
        BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        
        if ( isCapturingStillImage ) {
            // do flash bulb like animation
            flashView = [[UIView alloc] initWithFrame:[[self view] frame]];
            [flashView setBackgroundColor:[UIColor whiteColor]];
            [flashView setAlpha:0.f];
            [[[self view] window] addSubview:flashView];
            
            [UIView animateWithDuration:.3f
                             animations:^{ [flashView setAlpha:1.f]; }
             ];
        }
        else {
            [UIView animateWithDuration:.3f
                             animations:^{ [flashView setAlpha:0.f]; }
                             completion:^(BOOL finished){ [flashView removeFromSuperview]; }
             ];
        }
    }
}



// Utility methods
- (CGFloat) constrainFloat: (CGFloat) f byMin: (CGFloat) min andMax: (CGFloat) max {
    if (f > max) return max;
    else if (f < min) return min;
    else return f;
}

- (void) logPhotoSaveCompleted {
    NSLog(@"Photo Saved");
}

@end

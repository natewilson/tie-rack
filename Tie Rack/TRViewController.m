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
#import <UIKit/UISwipeGestureRecognizer.h>

@interface TRViewController ()
@property (strong, nonatomic) IBOutlet UIPageControl *tieIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *tieImageView;
@property (strong, nonatomic) TRTiesListModel *rack;
@property (nonatomic) CGFloat lastTieRotation;
@property (nonatomic) CGFloat lastTieScale;
@property (nonatomic) CGFloat lastTieYCoord;
@property (nonatomic) CGFloat firstTieYCoord;
@end

// Constants for limiting tie changes:
#define MAX_TIE_SCALE     1.6
#define MIN_TIE_SCALE     0.6
#define MIN_TIE_PAN     -80.0
#define MAX_TIE_PAN      80.0

@implementation TRViewController

// Properties exposed externally
@synthesize captureSession;
@synthesize previewLayer;

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
    NSInteger dir = [sender direction];
    if (dir == UISwipeGestureRecognizerDirectionLeft) {
        [self.tieImageView setImage:[self.rack nextTieImage]];
        [self.rack moveTiesToNext];
    } else if (dir == UISwipeGestureRecognizerDirectionRight) {
        [self.tieImageView setImage:[self.rack previousTieImage]];
        [self.rack moveTiesToPrevious];
    }
    // Update the paging indicator
    [self.tieIndicator setCurrentPage:[self.rack currentTieIndex]];
    NSLog(@"Swiped:%d",dir);
}
- (IBAction)rotate:(UIRotationGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
        sender.rotation = self.lastTieRotation;
    else if (sender.state == UIGestureRecognizerStateEnded)
        self.lastTieRotation = sender.rotation;
    self.tieImageView.transform = CGAffineTransformConcat(
            CGAffineTransformMakeRotation(sender.rotation),
            CGAffineTransformMakeScale(self.lastTieScale,self.lastTieScale)
                                                          );
}
- (IBAction)scaleTie:(UIPinchGestureRecognizer *)sender {
    CGFloat constrainedScale = [self constrainFloat: sender.scale
                                              byMin: MIN_TIE_SCALE
                                             andMax: MAX_TIE_SCALE];
    if (sender.state == UIGestureRecognizerStateBegan)
        sender.scale = self.lastTieScale;
    else if (sender.state == UIGestureRecognizerStateEnded)
        self.lastTieScale = constrainedScale;
    self.tieImageView.transform = CGAffineTransformConcat(
            CGAffineTransformMakeRotation(self.lastTieRotation),
            CGAffineTransformMakeScale(constrainedScale, constrainedScale)
                                                          );
}
// When connected to a pan gesture, this prevents swiping left/right from
// being recognized by the swipe gestures above.
- (IBAction)moveTie:(UIPanGestureRecognizer *)sender {
    UIView *context = [self.tieImageView superview];
    CGPoint constrainedCoord = [sender translationInView:context];
    constrainedCoord.y = [self constrainFloat: constrainedCoord.y
                                        byMin: MIN_TIE_PAN
                                       andMax: MAX_TIE_PAN];
    if (sender.state == UIGestureRecognizerStateBegan){
        constrainedCoord.y = self.lastTieYCoord;
        [sender setTranslation:constrainedCoord inView:context];
    } else if (sender.state == UIGestureRecognizerStateEnded){
        self.lastTieYCoord = constrainedCoord.y;
    }
    CGPoint newCenter;
    newCenter.x = [self.tieImageView center].x;
    newCenter.y = self.firstTieYCoord + constrainedCoord.y;
    [self.tieImageView setCenter:newCenter];
}
- (IBAction)takeSnapshot:(UIButton *)sender {
    TRPhotoBuilder *photographer = [[TRPhotoBuilder alloc] init];
    [photographer captureImage:self withTie:[self.rack currentTieImage]];
}

- (TRTiesListModel *) rack {
    // "lazy instantiation" pattern
    if (!_rack) _rack = [[TRTiesListModel alloc] init];
    return _rack;
}

- (CGFloat) lastTieScale {
    if (!_lastTieScale) _lastTieScale = 1.0;
    return _lastTieScale;
}

- (CGFloat) firstTieYCoord {
    if (!_firstTieYCoord) _firstTieYCoord = [self.tieImageView center].y;
    return _firstTieYCoord;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set the Initial Tie view to the currentTieImage
    [self.tieImageView setImage:[self.rack currentTieImage]];
    
    // Also setup the tieIndicator
    [self.tieIndicator setNumberOfPages:[self.rack numberOfTies]];
    [self.tieIndicator setCurrentPage:[self.rack currentTieIndex]];
    
    //add video input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (!error)
    {
        [[self captureSession] addInput:videoIn];
    }
    //add video preview layer
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //starting to set up the preview layer as a view
    CGRect layerRect = [[[self view] layer] bounds];
	[[self previewLayer] setBounds:layerRect];
	[[self previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
	//[[[self view] layer] addSublayer:[self previewLayer]];
    [[[self view] layer] insertSublayer:[self previewLayer] atIndex:0];
    //[[self view] addSubview:[self previewLayer]];
    
    // Add a scrolling rack view?
    TRScrollingTieRackView *rackView = [[TRScrollingTieRackView alloc] initWithFrame:CGRectMake(0, 60, 320, 380) andTieList:self.rack];
    [self.view addSubview:rackView];
    
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

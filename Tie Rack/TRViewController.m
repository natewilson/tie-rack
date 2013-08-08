//
//  TRViewController.m
//  Tie Rack
//
//  Created by Rene Candelier on 5/28/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRViewController.h"
#import "TRTiesListModel.h"
#import <UIKit/UISwipeGestureRecognizer.h>

@interface TRViewController ()
@property (strong, nonatomic) IBOutlet UIPageControl *tieIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *tieImageView;
@property (strong, nonatomic) TRTiesListModel *rack;
@end


@implementation TRViewController

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

- (TRTiesListModel *) rack {
    // "lazy instantiation" pattern
    if (!_rack) _rack = [[TRTiesListModel alloc] init];
    return _rack;
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
    
    //start the capture session
    [captureSession startRunning];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

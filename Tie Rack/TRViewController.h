//
//  TRViewController.h
//  Tie Rack
//
//  Created by Rene Candelier on 5/28/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "TRScrollingTieRackView.h"

@interface TRViewController : UIViewController <TRScrollingTieRackViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;

- (void) tieWillChange;

@end

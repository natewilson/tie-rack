//
//  TRPhotoBuilder.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/11/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "TRPhotoBuilder.h"

@interface TRPhotoBuilder ()
@end


@implementation TRPhotoBuilder

- (void) nilSelector {
    
}

- (void) captureImage: (TRViewController *) ctrl withTie:(UIImage *)tie{
    AVCaptureStillImageOutput *stillImageOut = [[AVCaptureStillImageOutput alloc] init];
    AVCaptureSession *session = ctrl.captureSession;
    
    // TODO: This might return false if the imageOut is already added?
    //       Should we remove it when done?
    if ([session canAddOutput:stillImageOut]) {
        NSLog(@"Can add camera to session");
        [session addOutput:stillImageOut];
        
        // Sift through the connections on the stillImageOut to find the inputPort.
        AVCaptureConnection *cnxn = nil;
        for (AVCaptureConnection *c in stillImageOut.connections){
            for (AVCaptureInputPort *p in c.inputPorts) {
                if ([[p mediaType] isEqual:AVMediaTypeVideo]) {
                    cnxn = c;
                    break;
                }
            }
            if (cnxn) break;
        }
        
        if (cnxn) {
            NSLog(@"Found camera connection");
        
            [stillImageOut captureStillImageAsynchronouslyFromConnection:cnxn completionHandler:^(CMSampleBufferRef buf, NSError *err){
                NSLog(@"Got something to handle (img/err?)");
                
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buf];
                UIImage *base = [[UIImage alloc] initWithData:imageData];
                
                // Merge images together
                UIGraphicsBeginImageContext(base.size);
                [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
                
                CGFloat scaleWidePixels = base.size.width  * 0.25;
                CGFloat scaleHighPixels = base.size.height * 0.25;
                
                [tie drawInRect:CGRectMake(scaleWidePixels, scaleHighPixels, base.size.width - scaleWidePixels, base.size.height - scaleHighPixels)];
                UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSLog(@"Have image... writing to Camera Roll...");
                UIImageWriteToSavedPhotosAlbum(final, nil, nil, nil);
                
                NSLog(@"Removing the stillImageOutput");
                [session removeOutput:stillImageOut];
            }];
        }
        
    } else {
        NSLog(@"Cannot add stillImageOut to captureSession.");
    }
}

- (id) init {
    self = [super init];
    if (self) {
        // Is any init needed?
    }
    return self;
}



@end

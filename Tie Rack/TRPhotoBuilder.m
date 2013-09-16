//
//  TRPhotoBuilder.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/11/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>
#import "TRPhotoBuilder.h"

@interface TRPhotoBuilder ()
@end


@implementation TRPhotoBuilder

- (void) nilSelector {
    
}

- (void) captureImage: (TRViewController *) ctrl withTie:(UIImage *)tie andTransform:(CGAffineTransform)ctm {

    
    AVCaptureStillImageOutput *stillImageOut = [[AVCaptureStillImageOutput alloc] init];
    AVCaptureSession *session = ctrl.captureSession;
    
    // TODO: This might return false if the imageOut is already added?
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
                
                // Try to make a UIImage out of what we have
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buf];
                UIImage *base = [[UIImage alloc] initWithData:imageData];
                
                // Setup an image context and get a reference to it.
                UIGraphicsBeginImageContext(base.size);
                CGContextRef refContext = UIGraphicsGetCurrentContext();
                
                // Start by drawing the base image.
                [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
                
                // Now hold onto the state because we're about to majorly mess things up.
                CGContextSaveGState(refContext);

                // Move the origin to the center so that we rotate and scale around this point
                CGContextTranslateCTM(refContext, base.size.width/2, base.size.height/2);
                
                // After re-centering, apply the same transform that the tie had.
                CGContextConcatCTM(refContext, ctm);
                
                // Draw with an adjusted center point.
                [tie drawInRect:CGRectMake(-base.size.width / 2, -base.size.height / 2,
                                           base.size.width, base.size.height)];
                
                // OK - restore the regular transform matrix
                CGContextRestoreGState(refContext);
                
                // Add a Tie Rack brand in the lower left.
                UIImage *branding = [UIImage imageNamed:@"TieRack-imageBrand"];
                [branding drawInRect:CGRectMake(10, base.size.height - 10 - branding.size.height,
                                                branding.size.width, branding.size.height)];
                
                // Now read it all back together.
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

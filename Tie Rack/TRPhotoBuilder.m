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

- (void) captureImage: (TRViewController *) ctrl withTie:(UIImage *)tie andTransform:(CGAffineTransform)ctm andTranslation:(CGPoint) translation {
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
                UIImage *originalPhoto = [[UIImage alloc] initWithData:imageData];
                NSLog(@"Base size %f, %f", originalPhoto.size.width, originalPhoto.size.height);
                
                // NOTE: SCALE UP!! (we have the resolution)
                CGSize previewSize = [[ctrl previewLayer] bounds].size;
                NSLog(@"Preview size %f, %f", previewSize.width, previewSize.height);
                CGFloat scale = MIN((CGFloat)originalPhoto.size.width / previewSize.width, (CGFloat)originalPhoto.size.height / previewSize.height);
                NSLog(@"Using a factor of %f and", scale);
                CGSize finalSize = CGSizeMake(scale * previewSize.width, scale * previewSize.height);
                NSLog(@"Scaling to %f, %f", finalSize.width, finalSize.height);
        
                
                // TODO - INTRODUCE AND OFFSET FOR THE BASE IMAGE.  EVERYTHING ELSE WORKS!!!!
                CGPoint offsets;
                offsets.x = (scale * previewSize.width  < originalPhoto.size.width ) ?
                            (originalPhoto.size.width - scale * previewSize.width) / 2.0 : 0;
                offsets.y = (scale * previewSize.height < originalPhoto.size.height) ?
                            (originalPhoto.size.height - scale * previewSize.height) / 2.0 : 0;
                NSLog(@"Offsetting by %f, %f", offsets.x, offsets.y);
                
                // Crop the new image
                CGRect cropRect = CGRectMake(0+offsets.x, 0+offsets.y, finalSize.width-offsets.x, finalSize.height-offsets.y);
                CGImageRef imageRef = CGImageCreateWithImageInRect([originalPhoto CGImage], cropRect);
                UIImage *base = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                // Now scale the translation to the new size and update the completed transformation for the tie.
                CGPoint scaledTranslation = CGPointMake(translation.x * scale, translation.y * scale);
                CGAffineTransform totalTransform = CGAffineTransformConcat(ctm,
                                                                           CGAffineTransformMakeTranslation(scaledTranslation.x,
                                                                                                            scaledTranslation.y));
                
                // Setup an image context and get a reference to it.  This is where we will build the image
                UIGraphicsBeginImageContext(finalSize);
                CGContextRef refContext = UIGraphicsGetCurrentContext();
                
                // Start by drawing the base image. (Hopefully in the refContext and not tieContextRef)
                [base drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
                
                // We'll draw the tie in a separate layer.
                // Create it first based on the size of the preview layer (so we match the scale the user sees)
                //CGSize tieLayerSize = [[ctrl previewLayer] bounds].size;
                //CGLayerRef tieLayer = CGLayerCreateWithContext(refContext, tieLayerSize, nil);
                //NSLog(@"tieLayerSize: %f, %f", tieLayerSize.width, tieLayerSize.height);
                // Then get a graphics context for the new layer
                //CGContextRef tieContextRef = CGLayerGetContext(tieLayer);
                // Now hold onto the state because we're about to majorly mess things up.
                //CGContextSaveGState(tieContextRef);
                // Move the origin to the center so that we rotate and scale around this point
                //CGContextTranslateCTM(tieContextRef, tieLayerSize.width/2, tieLayerSize.height/2);
                // After re-centering, apply the same transform that the tie had.
                //CGContextConcatCTM(tieContextRef, ctm);
                // Draw the tie image in the tie layer
                //CGContextDrawImage(tieContextRef, [[ctrl previewLayer] bounds], base.CGImage);
                // Now restore the layer state (might not be needed)
                //CGContextRestoreGState(tieContextRef);
                // NOW MOVING BACK TO MAIN CONTEXT
                
                // Now figure out a rectangle to draw the tieLayer within and draw it.
                //NSInteger scaleFactor = base.size.width / tieLayerSize.width;
                //NSInteger offset = (base.size.height - tieLayerSize.height) - 2;
                //CGRect tieRect = CGRectMake(0, offset, scaleFactor*tieLayerSize.width, scaleFactor*tieLayerSize.height);
                //CGContextDrawLayerInRect(refContext, tieRect, tieLayer);
        
                //** TIE DRAWING CODE...
                // Now hold onto the state because we're about to majorly mess things up.
                CGContextSaveGState(refContext);
                // Move the origin to the center so that we rotate and scale around this point
                CGContextTranslateCTM(refContext, finalSize.width/2, finalSize.height/2);
                // After re-centering, apply the same transform that the tie had.
                CGContextConcatCTM(refContext, totalTransform);
                // Draw with an adjusted center point.
                [tie drawInRect:CGRectMake(-finalSize.width / 2, -finalSize.height / 2,
                                           finalSize.width, finalSize.height)];
                // OK - restore the regular transform matrix
                CGContextRestoreGState(refContext);
                //*/
                
                // Add a Tie Rack brand in the lower left.
                UIImage *branding = [UIImage imageNamed:@"TieRack-imageBrand"];
                [branding drawInRect:CGRectMake(10, finalSize.height - 10 - branding.size.height,
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

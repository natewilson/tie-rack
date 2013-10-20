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
    AVCaptureStillImageOutput *stillImageOut = [ctrl getImageOut];
    
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
        //NSLog(@"Found camera connection");
        
        [stillImageOut captureStillImageAsynchronouslyFromConnection:cnxn completionHandler:^(CMSampleBufferRef buf, NSError *err){
            NSLog(@"Got something to handle (img/err?)");
            
            // Try to make a UIImage out of what we have
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:buf];
            UIImage *originalPhoto = [[UIImage alloc] initWithData:imageData];
            //NSLog(@"Original (i.e. camera) size %f, %f", originalPhoto.size.width, originalPhoto.size.height);
            
            // Getting ready to scale up (b/c we have the resolution) start with the size of the preview layer
            CGSize previewSize = [[ctrl previewLayer] bounds].size;
            //NSLog(@"Preview (i.e. screen) size %f, %f", previewSize.width, previewSize.height);
            
            // Figure out whether we scale by width or height - selecing the smallest factor to fill the entire area
            // Note: this assumes the photo from the camera has a greater resolution than the screen on the device
            CGFloat scale = MIN((CGFloat)originalPhoto.size.width / previewSize.width,
                                (CGFloat)originalPhoto.size.height / previewSize.height);
            //NSLog(@"Using a factor of %f and", scale);
            
            // Now build an object to hold onto our final size.
            CGSize finalSize = CGSizeMake(scale * previewSize.width, scale * previewSize.height);
            //NSLog(@"Scaling to %f, %f", finalSize.width, finalSize.height);
            
            // For both width and height check whether we need to offset the area of the photo to use
            // this helps us grab the actual portion used in the preview layer when showing video gravity that
            // fills the entire layer.  (Lots of guessing to get here... thanks Apple.)
            CGPoint offsets;
            offsets.x = (scale * previewSize.width  < originalPhoto.size.width ) ?
            (originalPhoto.size.width - scale * previewSize.width) / 2.0 : 0;
            offsets.y = (scale * previewSize.height < originalPhoto.size.height) ?
            (originalPhoto.size.height - scale * previewSize.height) / 2.0 : 0;
            //NSLog(@"Offsetting by %f, %f", offsets.x, offsets.y);
            
            // Crop the new image with a rectandle we're going to build
            CGRect cropRect;
            // Figure out whether we're cropping straight-ways or sideways (landscape) and build a rectangle with the right offset
            if (originalPhoto.imageOrientation == UIImageOrientationDown || originalPhoto.imageOrientation == UIImageOrientationUp) {
                cropRect = CGRectMake(0+offsets.x, 0+offsets.y, finalSize.width, finalSize.height);
            } else { // if we're in landscape just swap the x/y and width/height args to account for the change.
                //NSLog(@"Due to a landscape orientation...");
                cropRect = CGRectMake(0+offsets.y, 0+offsets.x, finalSize.height, finalSize.width);
            }
            //NSLog(@"Cropping area origin is: %f, %f \n\twith size: %f, %f",
            //      cropRect.origin.x, cropRect.origin.y,
            //      cropRect.size.width, cropRect.size.height);
            
            // Now slice that baby up just right
            CGImageRef imageRef = CGImageCreateWithImageInRect([originalPhoto CGImage], cropRect);
            // ...preserving the original orientation
            UIImage *base = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:originalPhoto.imageOrientation];
            // ...and cleaning up after ourselves.
            CGImageRelease(imageRef);
            
            // Current status
            // *base is a handle to the scaled up resolution of what the user saw on the screen
            
            // Setup an image context and get a reference to it.  This is where we will build the image
            UIGraphicsBeginImageContext(finalSize);
            CGContextRef refContext = UIGraphicsGetCurrentContext();
            
            // Now write our base image to the active context
            [base drawInRect:CGRectMake(0, 0, finalSize.width, finalSize.height)];
            
            
            // TIE DRAWING CODE
            // ================
            // Now scale the translation to the new size and update the completed transformation for the tie.
            CGPoint scaledTranslation = CGPointMake(translation.x * scale, translation.y * scale);
            // Get ready to build the final movement (I feel like Beethoven right now)
            CGAffineTransform totalTransform;
            // setup a transform based on the scaled translation (we adjusted this from screen-space to image-space)
            totalTransform = CGAffineTransformMakeTranslation(scaledTranslation.x, scaledTranslation.y);
            // Merge the scale/rotation transformation with the translation tranformation
            totalTransform = CGAffineTransformConcat(ctm, totalTransform);
            // Now hold onto the state because we're about to majorly mess things up (with that transform)
            CGContextSaveGState(refContext);
            // Move the origin to the center so that we rotate and scale around this point
            CGContextTranslateCTM(refContext, finalSize.width/2, finalSize.height/2);
            // After re-centering, apply the same transform that the tie had (adjusted for our image)
            CGContextConcatCTM(refContext, totalTransform);
            // Draw the tie with an adjusted center point and the transforms applied (args: x,y,width,height)
            [tie drawInRect:CGRectMake(-finalSize.width / 2, -finalSize.height / 2,
                                       finalSize.width, finalSize.height)];
            // OK - restore the regular transform matrix (extend arm, drop mic, walk out)
            CGContextRestoreGState(refContext);
            
            
            // Add a Tie Rack brand in the lower left.
            UIImage *branding = [UIImage imageNamed:@"TieRack-imageBrand"];
            [branding drawInRect:CGRectMake(10, finalSize.height - 10 - branding.size.height,
                                            branding.size.width, branding.size.height)];
            
            // Now read it all back together.
            UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            //NSLog(@"Have image... writing to Camera Roll...");
            UIImageWriteToSavedPhotosAlbum(final, nil, nil, nil);
            
            NSLog(@"Photo generated... writing to album");
            
        }];
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

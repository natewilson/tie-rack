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


// Create a UIImage from sample buffer data
// Copied from https://developer.apple.com/library/ios/qa/qa1702/_index.html
// For the record this initially creates 7 linker errors for armv7 builds even
// with the same #imports as specified at the URL above.
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}


@end

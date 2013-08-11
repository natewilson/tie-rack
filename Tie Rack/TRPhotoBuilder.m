//
//  TRPhotoBuilder.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/11/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TRPhotoBuilder.h"

@interface TRPhotoBuilder ()
@end


@implementation TRPhotoBuilder

- (void) captureImage: (TRViewController *) ctrl {
    AVCaptureStillImageOutput *stillImageOut = [[AVCaptureStillImageOutput alloc] init];
    AVCaptureSession *session = ctrl.captureSession;
    if ([session canAddOutput:stillImageOut]) {
        NSLog(@"Can add camera to session");
        [session addOutput:stillImageOut];
        
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
            }];
        }
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

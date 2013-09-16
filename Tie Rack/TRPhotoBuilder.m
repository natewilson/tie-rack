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

    UIImagePickerController *pickerController = ctrl.picker;
    [pickerController takePicture];

}

- (id) init {
    self = [super init];
    if (self) {
        // Is any init needed?
    }
    return self;
}



@end

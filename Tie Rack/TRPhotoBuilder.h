//
//  TRPhotoBuilder.h
//  Tie Rack
//
//  Created by Nate Wilson on 8/11/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRViewController.h"

@interface TRPhotoBuilder : NSObject

- (void) captureImage: (TRViewController *) ctrl withTie: (UIImage *)tie andTransform: (CGAffineTransform) ctm andTranslation:(CGPoint) translation;


@end

//
//  TRTiesListModel.h
//  Tie Rack
//
//  Created by Nate Wilson on 8/8/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TRTiesListModel : NSObject

@property (strong, readonly, nonatomic) UIImage *nextTieImage;
@property (strong, readonly, nonatomic) UIImage *previousTieImage;
@property (strong, readonly, nonatomic) UIImage *currentTieImage;

- (void) moveTiesToNext;
- (void) moveTiesToPrevious;

- (int) numberOfTies;
- (int) currentTieIndex;

@end

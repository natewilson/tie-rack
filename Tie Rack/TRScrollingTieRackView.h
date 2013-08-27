//
//  TRTiewRackView.h
//  Tie Rack
//
//  Created by Nate Wilson on 8/26/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRTiesListModel.h"
#import <UIKit/UIKit.h>


@protocol TRScrollingTieRackViewDelegate <NSObject>
@optional
- (void) tieWillChange;
- (void) tieDidChange;      // not implemented
@end



@interface TRScrollingTieRackView : UIScrollView <UIScrollViewDelegate>

// Set for all items in the scrolling view.
@property (nonatomic) CGAffineTransform transform;

// Do not init without a tiesListModel
- (id)initWithFrame:(CGRect)frame andTieList:(TRTiesListModel*)rack;

// Want to get notified?
- (void) addDelegate:(id<TRScrollingTieRackViewDelegate>) delegate;

@end


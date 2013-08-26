//
//  TRTiewRackView.h
//  Tie Rack
//
//  Created by Nate Wilson on 8/26/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRTiesListModel.h"
#import <UIKit/UIKit.h>

@interface TRScrollingTieRackView : UIScrollView <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame andTieList:(TRTiesListModel*)rack;

@end

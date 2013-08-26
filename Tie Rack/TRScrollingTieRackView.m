//
//  TRTiewRackView.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/26/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRScrollingTieRackView.h"
#import "TRTiesListModel.h"

@interface TRScrollingTieRackView ()

// Used for determining scroll behaviour
@property CGFloat lastShownXPos;
@property CGFloat scrollStopXPos;
@property BOOL watchingDirection;

// Used for performing "magic" image looping in scroller
@property BOOL waitingToShowRight;
@property BOOL waitingToShowLeft;

// Used for tie images and pre-loading
@property TRTiesListModel *rack;

// Used to build the scrolling content
@property UIImageView *leftView;
@property UIImageView *screenView;
@property UIImageView *rightView;

@end


@implementation TRScrollingTieRackView

- (id)initWithFrame:(CGRect)frame andTieList:(TRTiesListModel*)rack
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.rack = rack;
        self.waitingToShowLeft  = NO;
        self.waitingToShowRight = NO;
        
        // Enable paging and disable scrollbars.
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        // Set myself as the object for responding to events
        [self setDelegate:self];
        
        // setup the initial content size to have 1 extra tie to the left and right
        self.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
        
        // Make 3 tieViews
        self.leftView   = [[UIImageView alloc] initWithImage:[rack previousTieImage]];
        self.screenView = [[UIImageView alloc] initWithImage:[rack currentTieImage]];
        self.rightView  = [[UIImageView alloc] initWithImage:[rack nextTieImage]];
        
        // Then set the frames appropriately
        [self.leftView   setFrame:CGRectMake(0 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        [self.screenView setFrame:CGRectMake(1 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        [self.rightView  setFrame:CGRectMake(2 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        
        // Now add them all
        [self addSubview:self.leftView];
        [self addSubview:self.screenView];
        [self addSubview:self.rightView];
        
        // And position the view on the center tie
        [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
        
    }
    return self;
}

- (void) addTieRight {
    
    // Update the imageViews with new images.
    [self.leftView setImage: self.screenView.image];
    [self.screenView setImage: self.rightView.image];
    
    // AS SOON AS the screenView is reset with the right image move the content Offset to re-show it.
    [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
    
    // Then change the right image  (which was pre-loaded during scroll)
    [self.rightView setImage:[self.rack nextTieImage]];
    
    // Without setting needs display, the old image sometimes makes a cameo
    [self.rightView setNeedsDisplay];
}


- (void) addTieLeft {
    
    // Update the imageViews with new images.
    [self.rightView setImage: self.screenView.image];
    [self.screenView setImage: self.leftView.image];
    
    // AS SOON AS the screenView is reset with the left image move the content Offset to re-show it.
    [self setContentOffset:CGPointMake(self.frame.size.width, 0)];
    
    // Then change the left image  (which was pre-loaded during scroll)
    [self.leftView setImage:[self.rack previousTieImage]];
    
    // Without setting needs display, the old image sometimes makes a cameo
    [self.leftView setNeedsDisplay];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



// ======= DELEGATE PROTOCOL METHODS =======

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Only run this when we're looking for position changes AND they're happening.
    if (self.watchingDirection && self.contentOffset.x != self.scrollStopXPos) {
        
        // First handle a few cases where we don't really do anything (i.e. a scroll
        // action is just returning to the last known location).
        if ((self.contentOffset.x < self.scrollStopXPos && self.lastShownXPos < self.scrollStopXPos) ||
            (self.contentOffset.x > self.scrollStopXPos && self.lastShownXPos > self.scrollStopXPos)) {
            self.watchingDirection = NO;
            return;
        }
        
        // At this point we know we need to load something.  Just figure out which.
        if (self.contentOffset.x < self.scrollStopXPos) {
            
            // Load the previous tie image before the view stops scrolling.
            [self.rack moveTiesToPrevious];
            
            self.watchingDirection = NO;
            self.waitingToShowLeft = YES;
            
        } else if (self.contentOffset.x > self.scrollStopXPos) {
            
            // Load the next tie image before the view stops scrolling.
            [self.rack moveTiesToNext];
            
            self.watchingDirection  = NO;
            self.waitingToShowRight = YES;
        }
    }
}


// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // When a drag begins, save the x-coordinate in order to determine
    // whether we end up to the left or right when the drag stops.
    self.lastShownXPos = self.contentOffset.x;
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // Make a note of where the scroll stopped (to gauge direction of deceleration)
    self.scrollStopXPos = self.contentOffset.x;
    
    // Then start watching to see if we're decelerating to a new tie or the current one.
    self.watchingDirection = YES;
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // finally swap the ties and reset scrolling offsets (this is the magic!)
    
    // for either the right...
    if (self.waitingToShowRight) {
        [self addTieRight];
        self.waitingToShowRight = NO;
    }
    // ...or left ties appropriately
    if (self.waitingToShowLeft) {
        [self addTieLeft];
        self.waitingToShowLeft = NO;
    }
}

/* UNUSED Protocol Methods 
 
// called on finger up if the user dragged. velocity is in points/second.
// targetContentOffset may be changed to adjust where the scroll view comes
// to rest. not called when pagingEnabled is YES
//- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0) { NSLog(@"scrollViewWillEndDragging"); }
 
// any zoom scale changes
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2) { NSLog(@"scrollViewDidZoom"); }
 
// called on finger up as we are moving
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDecelerating at %f", self.contentOffset.x);
}///

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView { NSLog(@"scrollViewDidEndScrollingAnimation"); }

// return a view that will be scaled. if delegate returns nil, nothing happens
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView { NSLog(@"viewForZoomingInScrollView"); return nil; }

// called before the scroll view begins zooming its content
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2) { NSLog(@"scrollViewWillBeginZooming"); }

// scale between minimum and maximum. called after any 'bounce' animations
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale { NSLog(@"scrollViewDidEndZooming"); }

// return a yes if you want to scroll to the top. if not defined, assumes YES
//- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView { NSLog(@"scrollViewShouldScrollToTop"); return NO; }

// called when scrolling animation finished. may be called immediately if already at top
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView { NSLog(@"scrollViewDidScrollToTop"); }

//*/ // <<< UNUSED Protocol Methods

@end

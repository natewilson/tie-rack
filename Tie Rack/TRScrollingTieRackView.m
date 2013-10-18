//
//  TRTiewRackView.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/26/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//
//
//  Basic Principles:
//
//  1.) Three underlying images:
//  The Scrolling Tie Rack View never uses more than three UIImage views in
//  the content area it contains.  When a scroll is detected to the left, the
//  object begins to load the next left image while the scroll animation is
//  active.  Once the animation ends, the object will shift all images to the
//  right while simultaneously re-positioning the content area on the center
//  image (the "screenView" UIImageView instance).  This creates the effect
//  that the user has actually moved one image to the left.
//  
//  2.) Shared transformation:
//  The Scrolling Tie Rack View will dispatch new transform objects to all
//  three of the images that appear in the content area.  This way, when
//  manipulating the rotation, scale, etc. of the content, all images receive
//  the same treatment.  

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

// Anyone want to know when things change?
@property (nonatomic) NSMutableArray *delegates;

@end


@implementation TRScrollingTieRackView

@synthesize transform = _transform;

// Lazy instantiation that gives us space for one something.
- (NSMutableArray *) delegates {
    if (!_delegates) _delegates = [[NSMutableArray alloc] initWithCapacity:1];
    return _delegates;
}

// Nope sorry - you can't remove these.  No takebacks.
- (void) addDelegate:(id<TRScrollingTieRackViewDelegate>)delegate {
    [self.delegates addObject:delegate];
}

// Dispatches a message to all delegates that can understand it.
- (void) tellDelegatesTieWillChange {
    for (id<TRScrollingTieRackViewDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(tieWillChange)]) {
            [delegate tieWillChange];
        }
    }
}

- (id)initWithFrame:(CGRect)frame andTieList:(TRTiesListModel*)rack
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.rack = rack;
        self.waitingToShowLeft  = NO;
        self.waitingToShowRight = NO;
        self.transform = CGAffineTransformMakeTranslation(0, 0); // No transform
        
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

- (void) setTransform:(CGAffineTransform)transform {
    
    // Set our transform WITHOUT translation:
    _transform = transform;
    
    // Start with our existing transform and apply the translation last
    CGAffineTransform composite = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(self.translation.x, self.translation.y));
    
    // Finally, subviews should reflect both in their composite transforms
    self.leftView.transform = composite;
    self.screenView.transform = composite;
    self.rightView.transform = composite;

}

- (void) setTranslation:(CGPoint)translation {
    
    // Set our translation WITHOUT transform(scale/rotate)
    _translation = translation;
    
    // Start with our existing transform and apply the translation last
    CGAffineTransform composite = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(translation.x, translation.y));

    // Finally, subviews should reflect both in their composite transforms
    self.leftView.transform = composite;
    self.screenView.transform = composite;
    self.rightView.transform = composite;
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
            
            [self tellDelegatesTieWillChange];
            
        } else if (self.contentOffset.x > self.scrollStopXPos) {
            
            // Load the next tie image before the view stops scrolling.
            [self.rack moveTiesToNext];
            
            self.watchingDirection  = NO;
            self.waitingToShowRight = YES;
            
            [self tellDelegatesTieWillChange];
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

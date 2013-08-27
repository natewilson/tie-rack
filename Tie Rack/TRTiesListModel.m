//
//  TRTiesListModel.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/8/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRTiesListModel.h"

@interface TRTiesListModel()
@property (strong, nonatomic) NSArray *tieNames;
@property (nonatomic) int currentTieIndex;
// lines below are readonly properties in the public interface
@property (strong, readwrite, nonatomic) UIImage *nextTieImage;
@property (strong, readwrite, nonatomic) UIImage *previousTieImage;
@property (strong, readwrite, nonatomic) UIImage *currentTieImage;
@end

@implementation TRTiesListModel

// Custom init method loads three images to start with.
- (id) init {
    self = [super init];
    
    // [super init] might be nil
    if (self) {
        // currentTieIndex inits to 0: safe except for nil arrays of ties
        // currentTieIndex is init'd in the accessor below.
        int nextIndex = [self safeIndex: (self.currentTieIndex+1)
                                    for: self.tieNames];
        int prevIndex = [self safeIndex: (self.currentTieIndex-1)
                                    for: self.tieNames];
    
        self.currentTieImage = [UIImage imageNamed:self.tieNames[0]];
        self.nextTieImage = [UIImage imageNamed:self.tieNames[nextIndex]];
        self.previousTieImage = [UIImage imageNamed:self.tieNames[prevIndex]];
    }
    
    return self;
}

// Utility method to loop array indices to safe values
- (int) safeIndex: (int) index for: (NSArray *)array{
    return (index + [array count]) % [array count];
}

// Accessor methods
- (NSArray *) tieNames {
    if (!_tieNames) _tieNames = @[
                                  @"fruitypepples",
                                  @"leadercast",
                                  @"leadercast-grey",
                                  @"icon-green",
                                  @"icon-yellow",
                                  @"orange",
                                  @"usa",
                                  @"college-kickoff"
                                  ];
    return _tieNames;
}
- (int) numberOfTies {
    return [self.tieNames count];
}
- (int) currentTieIndex {
    if (!_currentTieIndex) _currentTieIndex = 0;
    return _currentTieIndex;
}

// Use these after accessing a prev/next image to begin loading
// the new prev/next image accordingly.  Ties don't cycle without this.
- (void) moveTiesToNext {
    // increment the counter for the currentIndex.
    self.currentTieIndex = [self safeIndex: (self.currentTieIndex+1)
                                       for: self.tieNames];
    
    // cycle the previous and current images (dropping reference to prev)
    self.previousTieImage = self.currentTieImage;
    self.currentTieImage = self.nextTieImage;
    
    // still have to +1 the index to get the next image (or loop)
    // because now the currentIndex points to the new currentIndex
    self.nextTieImage = [UIImage imageNamed:self.tieNames[[self safeIndex:(self.currentTieIndex+1) for:self.tieNames]]];
}
- (void) moveTiesToPrevious {
    // decrement the counter for the currentIndex.
    self.currentTieIndex = [self safeIndex: (self.currentTieIndex-1)
                                       for: self.tieNames];
    
    // cycle the next and current images (dropping reference to next)
    self.nextTieImage = self.currentTieImage;
    self.currentTieImage = self.previousTieImage;
    
    // still have to -1 the index to get the previous image (or loop)
    // because now the currentIndex points to the new currentIndex
    self.previousTieImage = [UIImage imageNamed:self.tieNames[[self safeIndex:(self.currentTieIndex-1) for:self.tieNames]]];
}

@end









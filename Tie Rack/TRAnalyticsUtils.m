//
//  TRAnalyticsUtils.m
//  Tie Rack
//
//  Created by Nate Wilson on 8/9/13.
//  Copyright (c) 2013 iOS Study Group. All rights reserved.
//

#import "TRAnalyticsUtils.h"

@implementation TRAnalyticsUtils

+ (NSString *) GATrackerCode {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GA-Tracker-ID" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!content)
        NSLog(@"WARNING: GA-Tracker-ID.txt not found.");
    return (content) ? content : @"UA-NOT-FOUND";
}

@end
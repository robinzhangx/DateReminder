//
//  GoogleAnalyticsHelper.m
//  DateReminder
//
//  Created by robin on 1/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "GoogleAnalyticsHelper.h"

@implementation GoogleAnalyticsHelper

+ (void)trackScreen:(NSString *)screenName
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                         action:action
                                                          label:label
                                                          value:value] build]];
}

@end

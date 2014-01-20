//
//  GoogleAnalyticsHelper.h
//  DateReminder
//
//  Created by robin on 1/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const GA_CATEGORY_USER = @"User";
static NSString *const GA_CATEGORY_ERROR = @"Error";

static NSString *const GA_ACTION_CREATE_EVENT = @"Create Event";
static NSString *const GA_ACTION_CREATE_INVALIDATE = @"Create Event Invalidate";
static NSString *const GA_ACTION_DELETE_EVENT = @"Delete Event";
static NSString *const GA_ACTION_LOCAL_NOTIFICATION_EXCEED = @"Local Notification Exceed Maximum";
static NSString *const GA_ACTION_CONTACT_AUTHOR = @"Contact Author";
static NSString *const GA_ACTION_BUY_COFFEE = @"Buy Coffee";

static NSString *const GA_LABEL_CREATE_EVENT = @"Type:%@ Reminder:%@";
static NSString *const GA_LABEL_DELETE_EVENT = @"Type:%@";

@interface GoogleAnalyticsHelper : NSObject

+ (void)trackScreen:(NSString *)screenName;
+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

@end

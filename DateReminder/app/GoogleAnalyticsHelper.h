//
//  GoogleAnalyticsHelper.h
//  DateReminder
//
//  Created by robin on 1/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBZDateReminder.h"

static NSString *const GA_CATEGORY_UI           = @"UI";
static NSString *const GA_CATEGORY_PURCHASE     = @"Purchase";
static NSString *const GA_CATEGORY_NEW_EVENT    = @"New Event";
static NSString *const GA_CATEGORU_DELETE_EVENT = @"Delete Event";
static NSString *const GA_CATEGORY_ERROR        = @"Error";


static NSString *const GA_ACTION_SHOW_CREATE_POPUP          = @"Show Create Popup";
static NSString *const GA_ACTION_OPEN_TODAY_PAGE            = @"Open Today Page";
static NSString *const GA_ACTION_OPEN_TOMORROW_PAGE         = @"Open Tomorrow Page";
static NSString *const GA_ACTION_CLICK_HUD                  = @"Click Heads-up Display";
static NSString *const GA_ACTION_OPEN_SETTINGS              = @"Open Settings";
static NSString *const GA_ACTION_CHANGE_FROM_ARCHIVE        = @"Change From Archive";
static NSString *const GA_ACTION_DISCARD_CREATE             = @"Discard Create";
static NSString *const GA_ACTION_DELETE_BUTTON              = @"Delete Button";
static NSString *const GA_ACTION_TIME_BUTTON                = @"Time Button";
static NSString *const GA_ACTION_DATE_BUTTON                = @"Date Button";
static NSString *const GA_ACTION_REMINDER_BUTTON            = @"Reminder Button";
static NSString *const GA_ACTION_TIME_BADGE                 = @"Time Badge";
static NSString *const GA_ACTION_DATE_BADGE                 = @"Date Badge";
static NSString *const GA_ACTION_REMINDER_BADGE             = @"Reminder Badge";
static NSString *const GA_ACTION_DATE_FROM_QUICK_PICKER     = @"Date From Quick Picker";
static NSString *const GA_ACTION_DATE_FROM_PICKER_VIEW      = @"Date From Picker View";
static NSString *const GA_ACTION_CONTACT_AUTHOR             = @"Contact Author";
static NSString *const GA_ACTION_BUY_COFFEE                 = @"Buy Coffee";
static NSString *const GA_ACTION_RATE_APP                   = @"Rate App";
static NSString *const GA_ACTION_DELETE_FROM_ARCHIVE        = @"Delete From Archive";
static NSString *const GA_ACTION_CREATE_INVALIDATE          = @"Create Event Invalidate";
static NSString *const GA_ACTION_CHANGE_THEME_COLOR         = @"Change Theme Color";

static NSString *const GA_ACTION_READY_FOR_PURCHASE         = @"Ready For Purchase";
static NSString *const GA_ACTION_STORE_NOT_AVAILABLE        = @"Store Not Available";
static NSString *const GA_ACTION_ITEM_PURCHASED             = @"Item Purchased";
static NSString *const GA_ACTION_PURCHASE_FAILED            = @"Purchase Failed";

static NSString *const GA_ACTION_LOCAL_NOTIFICATION_EXCEED  = @"Local Notification Exceed Maximum";

@interface GoogleAnalyticsHelper : NSObject

+ (void)trackScreen:(NSString *)screenName;
+ (void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;

+ (void)trackCreateEvent:(Event *)event;
+ (void)trackDeleteEvent:(Event *)event;

@end

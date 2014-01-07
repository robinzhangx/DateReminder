//
//  RBZDateReminderApp.h
//  Date Reminder
//
//  Created by robin on 13-12-4.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event+Functions.h"
#import "EventDate+Functions.h"
#import "EventTime+Functions.h"
#import "EventReminder+Functions.h"

static NSString *FLURRY_CREATE_EVENT = @"create_event";
static NSString *FLURRY_CREATE_EVENT_INVALIDATE = @"create_event_invalidate";
static NSString *FLURRY_DELETE_EVENT = @"delete_event";
static NSString *FLURRY_CONTACT_AUTHOR = @"contact_author";
static NSString *FLURRY_BUY_COFFEE = @"buy_coffee";
static NSString *FLURRY_LOCAL_NOTIFICATION_MAXIMUM_REACHED = @"local_notification_maximun_reached";


@interface RBZDateReminder : NSObject

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIDatePicker *timePicker;

- (void)addEvent:(Event *)ev;
- (void)removeEvent:(Event *)ev;
- (void)updateEvent:(Event *)ev;
- (NSMutableArray *)getTodayEvents;
- (NSMutableArray *)getTomorrowEvents;
- (NSMutableArray *)getExpiredEvents;
- (NSMutableArray *)getActiveEvents;

//- (void)removeDangingLocalNotifications;

+ (RBZDateReminder *)instance;

@end

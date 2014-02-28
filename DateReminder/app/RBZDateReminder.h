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

@interface RBZDateReminder : NSObject

@property NSCalendar *defaultCalendar;
@property NSLocale *defaultLocale;

- (NSDateFormatter *)getLocalizedDateFormatter;
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

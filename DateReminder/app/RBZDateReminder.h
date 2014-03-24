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
#import "DRTheme.h"

UIKIT_EXTERN NSString *const DRThemeColorChangedNotification;

static const int kThemeColorDefault = 0;
static const int kThemeColorGreen = 1;
static const int kThemeColorBlue = 2;
static const int kThemeColorPurple = 3;

@interface RBZDateReminder : NSObject

@property NSCalendar *defaultCalendar;
@property NSLocale *defaultLocale;
@property DRTheme *theme;

- (NSDateFormatter *)getLocalizedDateFormatter;
- (void)setThemeColor:(int)index;
- (NSInteger)getThemeColor;
- (void)addEvent:(Event *)ev;
- (void)removeEvent:(Event *)ev;
- (void)updateEvent:(Event *)ev;
- (NSMutableArray *)getTodayEvents;
- (NSMutableArray *)getTomorrowEvents;
- (NSMutableArray *)getExpiredEvents;
- (NSMutableArray *)getActiveEvents;

//- (void)removeDangingLocalNotifications;

+ (RBZDateReminder *)instance;
+ (NSString *)getThemeColorName:(int)index;

@end

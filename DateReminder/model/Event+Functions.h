//
//  Event+Functions.h
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "Event.h"

@interface Event (Functions)

- (BOOL)isOnDate:(NSDate *)date;
- (BOOL)isExpired:(NSDate *)now;
+ (BOOL)isExpired:(NSDate *)now type:(NSNumber *)type minute:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day weekday:(NSNumber *)weekday month:(NSNumber *)month year:(NSNumber *)year;
- (NSDate *)getNextDate;
+ (NSDate *)getNextDate:(NSNumber *)type minute:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day weekday:(NSNumber *)weekday month:(NSNumber *)month year:(NSNumber *)year;
+ (NSDate *)nextDailyDate:(NSNumber *)minute hour:(NSNumber *)hour;
+ (NSDate *)nextWeeklyDate:(NSNumber *)minute hour:(NSNumber *)hour weekday:(NSNumber *)weekday;
+ (NSDate *)nextMonthlyDate:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day;
+ (NSDate *)nextYearlyDate:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day month:(NSNumber *)month;
+ (NSDate *)nextOnceDate:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year;

@end

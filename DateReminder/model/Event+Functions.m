//
//  Event+Functions.m
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "Event+Functions.h"
#import "EventTime+Functions.h"
#import "EventDate+Functions.h"
#import "EventReminder+Functions.h"

@implementation Event (Functions)

- (BOOL)isOnDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger units = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfYearCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *comps = [gregorian components:units fromDate:date];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger weekday = [comps weekday];
    
    switch ([self.date.type integerValue]) {
        case RBZEventOnce:
            if ([self.date.year integerValue] == year && [self.date.month integerValue] == month && [self.date.day integerValue] == day)
                return YES;
            break;
        case RBZEventYearly:
            if ([self.date.month integerValue] == month && [self.date.day integerValue] == day)
                return YES;
            break;
        case RBZEventMonthly:
            if ([self.date.day integerValue] == day)
                return YES;
            break;
        case RBZEventWeekly:
            if ([self.date.weekday integerValue] == weekday)
                return YES;
            break;
        case RBZEventDaily:
            return YES;
    }
    return NO;
}

- (BOOL)isExpired:(NSDate *)now
{
    return [Event isExpired:now
                       type:self.date.type
                     minute:self.time.minute
                       hour:self.time.hour
                        day:self.date.day
                    weekday:self.date.weekday
                      month:self.date.month
                       year:self.date.year];
}

+ (BOOL)isExpired:(NSDate *)now type:(NSNumber *)type minute:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day weekday:(NSNumber *)weekday month:(NSNumber *)month year:(NSNumber *)year
{
    if ([type integerValue] == RBZEventOnce) {
        NSDate *next = [Event getNextDate:type
                                   minute:minute
                                     hour:hour
                                      day:day
                                  weekday:weekday
                                    month:month
                                     year:year];
        if ([next timeIntervalSinceDate:now] <= 0)
            return YES;
    }
    return NO;
}

- (NSDate *)getNextDate
{
    return [Event getNextDate:self.date.type
                       minute:self.time.minute
                         hour:self.time.hour
                          day:self.date.day
                      weekday:self.date.weekday
                        month:self.date.month
                         year:self.date.year];
}

+ (NSDate *)getNextDate:(NSNumber *)type minute:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day weekday:(NSNumber *)weekday month:(NSNumber *)month year:(NSNumber *)year
{
    switch ([type integerValue]) {
        case RBZEventDaily: return [Event nextDailyDate:minute hour:hour];
        case RBZEventWeekly: return [Event nextWeeklyDate:minute hour:hour weekday:weekday];
        case RBZEventMonthly: return [Event nextMonthlyDate:minute hour:hour day:day];
        case RBZEventYearly: return [Event nextYearlyDate:minute hour:hour day:day month:month];
        case RBZEventOnce: return [Event nextOnceDate:minute hour:hour day:day month:month year:year];
    }
    return nil;
}


+ (NSDate *)nextDailyDate:(NSNumber *)minute hour:(NSNumber *)hour
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger units = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [gregorian components:units fromDate:now];
    now = [gregorian dateFromComponents:nowComps];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.minute = [minute integerValue];
    comps.hour = [hour integerValue];
    comps.day = nowComps.day;
    comps.month = nowComps.month;
    comps.year = nowComps.year;
    NSDate *d = [gregorian dateFromComponents:comps];
    if ([d timeIntervalSinceDate:now] <= 0) {
        NSDateComponents *add = [[NSDateComponents alloc] init];
        add.day = 1;
        return [gregorian dateByAddingComponents:add toDate:d options:0];
    } else {
        return d;
    }
}

+ (NSDate *)nextWeeklyDate:(NSNumber *)minute hour:(NSNumber *)hour weekday:(NSNumber *)weekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger units = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [gregorian components:units fromDate:now];
    now = [gregorian dateFromComponents:nowComps];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.minute = [minute integerValue];
    comps.hour = [hour integerValue];
    comps.weekday = [weekday integerValue];
    comps.week = nowComps.week;
    comps.year = nowComps.year;
    NSDate *d = [gregorian dateFromComponents:comps];
    if ([d timeIntervalSinceDate:now] <= 0) {
        NSDateComponents *add = [[NSDateComponents alloc] init];
        add.week = 1;
        return [gregorian dateByAddingComponents:add toDate:d options:0];
    } else {
        return d;
    }
}

+ (NSDate *)nextMonthlyDate:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger units = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [gregorian components:units fromDate:now];
    
    BOOL passed = [EventTime isTimePassed:minute
                                eventHour:hour
                            currentMinute:nowComps.minute
                              currentHour:nowComps.hour];
    nowComps.minute = [minute integerValue];
    nowComps.hour = [hour integerValue];
    
    NSInteger sd = [day integerValue];
    if (nowComps.day < sd) {
        if (sd == 31) {
            nowComps.day = [Event lastDayOfMonth:nowComps.month year:nowComps.year];
            return [gregorian dateFromComponents:nowComps];
        } else if (sd == 30 && nowComps.month == 2) {
            nowComps.day = sd;
            nowComps.month = 3;
            return [gregorian dateFromComponents:nowComps];
        } else if (sd == 29 && nowComps.month == 2) {
            if ([Event isLeapYear:nowComps.year]) {
                nowComps.day = sd;
                return [gregorian dateFromComponents:nowComps];
            } else {
                nowComps.day = sd;
                nowComps.month = 3;
                return [gregorian dateFromComponents:nowComps];
            }
        } else {
            nowComps.day = sd;
            return [gregorian dateFromComponents:nowComps];
        }
    } else if (nowComps.day == sd && !passed) {
        return [gregorian dateFromComponents:nowComps];
    } else {
        if (sd == 31) {
            if (nowComps.month == 12) {
                nowComps.month = 1;
                nowComps.year++;
                nowComps.day = [Event lastDayOfMonth:nowComps.month year:nowComps.year];
            } else {
                nowComps.month++;
                nowComps.day = [Event lastDayOfMonth:nowComps.month year:nowComps.year];
            }
            return [gregorian dateFromComponents:nowComps];
        } else if (sd == 30 && nowComps.month == 1) {
            nowComps.day = sd;
            nowComps.month = 3;
            return [gregorian dateFromComponents:nowComps];
        } else if (sd == 29 && nowComps.month == 1) {
            nowComps.day = sd;
            if ([Event isLeapYear:nowComps.year])
                nowComps.month = 2;
            else
                nowComps.month = 3;
            return [gregorian dateFromComponents:nowComps];
        } else {
            nowComps.day = sd;
            NSDate *d = [gregorian dateFromComponents:nowComps];
            NSDateComponents *add = [[NSDateComponents alloc] init];
            add.month = 1;
            return [gregorian dateByAddingComponents:add toDate:d options:0];
        }
    }
}

+ (NSDate *)nextYearlyDate:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day month:(NSNumber *)month
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger units = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDate *now = [NSDate date];
    NSDateComponents *nowComps = [gregorian components:units fromDate:now];
    now = [gregorian dateFromComponents:nowComps];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    NSInteger sd = [day integerValue];
    NSInteger sm = [month integerValue];
    
    comps.minute = [minute integerValue];
    comps.hour = [hour integerValue];
    comps.day = sd;
    comps.month = sm;
    if (sd == 29 && sm == 2) {
        if ([Event isLeapYear:nowComps.year])
            comps.year = nowComps.year;
        else
            comps.year = [Event nextLeapYear:nowComps.year];
    } else {
        comps.year = nowComps.year;
    }
    NSDate *d = [gregorian dateFromComponents:comps];
    if ([d timeIntervalSinceDate:now] <= 0) {
        if (sd == 29 && sm == 2) {
            comps.year = [Event nextLeapYear:nowComps.year];
            return [gregorian dateFromComponents:comps];
        } else {
            NSDateComponents *add = [[NSDateComponents alloc] init];
            add.year = 1;
            return [gregorian dateByAddingComponents:add toDate:d options:0];
        }
    } else {
        return d;
    }
}

+ (NSDate *)nextOnceDate:(NSNumber *)minute hour:(NSNumber *)hour day:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = [year integerValue];
    comps.month = [month integerValue];
    comps.day = [day integerValue];
    comps.hour = [hour integerValue];
    comps.minute = [minute integerValue];
    return [gregorian dateFromComponents:comps];
}

+ (BOOL)has31th:(NSInteger)month
{
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
        return YES;
    return NO;
}

+ (NSInteger)lastDayOfMonth:(NSInteger)month year:(NSInteger)year
{
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
        case 4:
        case 6:
        case 9:
        case 11:
            return 30;
        case 2:
            if ([self isLeapYear:year])
                return 29;
            else
                return 28;
    }
    return 31;
    
}

+ (NSInteger)lastDayOfNextMonth:(NSInteger)month year:(NSInteger)year
{
    switch (month) {
        case 1:
            if ([self isLeapYear:year])
                return 29;
            else
                return 28;
        case 2:
        case 4:
        case 6:
        case 7:
        case 9:
        case 11:
        case 12:
            return 31;
        case 3:
        case 5:
        case 8:
        case 10:
            return 30;
    }
    return 31;
}

+ (NSInteger)next31th:(NSInteger)month
{
    switch (month) {
        case 1:
        case 2:
            return 3;
        case 3:
        case 4:
            return 5;
        case 5:
        case 6:
            return 7;
        case 7:
            return 8;
        case 8:
        case 9:
            return 10;
        case 10:
        case 11:
            return 12;
        case 12:
            return 1;
    }
    return 1;
}

+ (BOOL)isLeapYear:(NSInteger)year
{
    if (year % 400 == 0) {
        return YES;
    } else if (year % 100 == 0) {
        return NO;
    } else if (year % 4 == 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSInteger)nextLeapYear:(NSInteger)year
{
    NSInteger next = year + (4 - year % 4);
    if (![self isLeapYear:next]) {
        next += 4;
    }
    return next;
}

@end

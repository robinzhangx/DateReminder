//
//  EventTime+Functions.m
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "EventTime+Functions.h"
#import "RBZDateReminder.h"

@implementation EventTime (Functions)

- (BOOL)isTimePassed:(NSInteger)minute hour:(NSInteger)hour
{
    return [EventTime isTimePassed:self.minute
                         eventHour:self.hour
                     currentMinute:minute
                       currentHour:hour];
}

+ (BOOL)isTimePassed:(NSNumber *)eventMinute eventHour:(NSNumber *)eventHour currentMinute:(NSInteger)currentMinute currentHour:(NSInteger)currentHour
{
    NSInteger em = [eventMinute integerValue];
    NSInteger eh = [eventHour integerValue];
    if (eh < currentHour) {
        return YES;
    } else if (eh == currentHour) {
        if (em <= currentMinute) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (NSString *)getTimeString
{
    return [EventTime getTimeString:self.minute hour:self.hour];
}

+ (NSString *)getTimeString:(NSNumber *)minute hour:(NSNumber *)hour
{
    NSCalendar *calendar = [[RBZDateReminder instance] defaultCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.hour = [hour integerValue];
    comps.minute = [minute integerValue];
    NSDate* date = [calendar dateFromComponents:comps];
    NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    return [formatter stringFromDate:date];
}

@end

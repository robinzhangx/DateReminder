//
//  EventReminder+Functions.m
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "EventReminder+Functions.h"

@implementation EventReminder (Functions)

- (NSString *)getReminderString
{
    return [EventReminder getReminderString:self.hasReminder minutes:self.minutesBefore];
}

+ (NSString *)getReminderString:(NSNumber *)hasReminder minutes:(NSNumber *)minutes
{
    NSInteger m = [minutes integerValue];
    if (![hasReminder boolValue])
        return @"No reminder";
    if (m == 1) {
        return @"1 minute earlier";
    } else if (m == 60) {
        return @"1 hour earlier";
    } else {
        return [NSString stringWithFormat:@"%d minutes earlier", m];
    }
}

@end

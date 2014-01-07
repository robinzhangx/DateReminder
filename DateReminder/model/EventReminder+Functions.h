//
//  EventReminder+Functions.h
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "EventReminder.h"

@interface EventReminder (Functions)

- (NSString *)getReminderString;
+ (NSString *)getReminderString:(NSNumber *)hasReminder minutes:(NSNumber *)minutes;

@end

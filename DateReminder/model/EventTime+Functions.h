//
//  EventTime+Functions.h
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "EventTime.h"

@interface EventTime (Functions)

- (BOOL)isTimePassed:(NSInteger)minute hour:(NSInteger)hour;
+ (BOOL)isTimePassed:(NSNumber *)eventMinute eventHour:(NSNumber *)eventHour currentMinute:(NSInteger)currentMinute currentHour:(NSInteger)currentHour;
- (NSString *)getTimeString;
+ (NSString *)getTimeString:(NSNumber *)minute hour:(NSNumber *)hour;

@end

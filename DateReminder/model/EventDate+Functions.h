//
//  EventDate+Functions.h
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "EventDate.h"

typedef enum {
    RBZEventOnce    = 1,
    RBZEventDaily   = 2,
    RBZEventWeekly  = 3,
    RBZEventMonthly = 4,
    RBZEventYearly  = 5
} RBZEventDateType;

@interface EventDate (Functions)

+ (NSString *)typeString:(NSInteger)type;
- (NSString *)getTypeString;
+ (NSString *)getDailyString;
+ (NSString *)getDailyValueString;
+ (NSString *)getWeeklyString:(NSNumber *)weekday;
+ (NSString *)getWeeklyValueString:(NSNumber *)weekday;
+ (NSString *)getMonthlyString:(NSNumber *)day;
+ (NSString *)getMonthlyValueString:(NSNumber *)day;
+ (NSString *)getYearlyString:(NSNumber *)day month:(NSNumber *)month;
+ (NSString *)getYearlyValueString:(NSNumber *)day month:(NSNumber *)month;
+ (NSString *)getOnceString:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year;
+ (NSString *)getOnceValueString:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year;


@end

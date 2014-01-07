//
//  EventDate+Functions.m
//  Date Reminder
//
//  Created by robin on 14-1-1.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "EventDate+Functions.h"

@implementation EventDate (Functions)

- (NSString *)getTypeString
{
    switch ([self.type integerValue]) {
        case RBZEventOnce: return [EventDate getOnceString:self.day month:self.month year:self.year];
        case RBZEventYearly: return [EventDate getYearlyString:self.day month:self.month];
        case RBZEventMonthly: return [EventDate getMonthlyString:self.day];
        case RBZEventWeekly: return [EventDate getWeeklyString:self.weekday];
        case RBZEventDaily: return [EventDate getDailyString];
    }
    return @"";
}

+ (NSString *)getOnceString:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year
{
    return [EventDate getOnceValueString:day month:month year:year];
}

+ (NSString *)getOnceValueString:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = [day integerValue];
    comps.month = [month integerValue];
    comps.year = [year integerValue];
    NSDate* date = [gregorian dateFromComponents:comps];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)getDailyString
{
    return @"Everyday";
}

+ (NSString *)getDailyValueString
{
    return @"";
}

+ (NSString *)getWeeklyString:(NSNumber *)weekday
{
    return [NSString stringWithFormat:@"Every %@", [self getWeeklyValueString:weekday]];
}

+ (NSString *)getWeeklyValueString:(NSNumber *)weekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:gregorian];
    return [formatter weekdaySymbols][[weekday integerValue] - 1];
}

+ (NSString *)getMonthlyString:(NSNumber *)day
{
    return [NSString stringWithFormat:@"%@ of every month", [EventDate getMonthlyValueString:day]];
}

+ (NSString *)getMonthlyValueString:(NSNumber *)day
{
    NSInteger d = [day integerValue];
    if (d == 1) {
        return @"1st";
    } else if (d == 2) {
        return @"2nd";
    } else if (d == 3) {
        return @"3rd";
    } else if (d == 31) {
        return @"Last day";
    } else {
        return [NSString stringWithFormat:@"%ldth", (long)d];
    }
}

+ (NSString *)getYearlyString:(NSNumber *)day month:(NSNumber *)month
{
    return [NSString stringWithFormat:@"Every %@", [EventDate getYearlyValueString:day month:month]];
}

+ (NSString *)getYearlyValueString:(NSNumber *)day month:(NSNumber *)month
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:gregorian];
    return [NSString stringWithFormat:@"%@ %ld", [formatter monthSymbols][[month integerValue] - 1], [day integerValue]];

}

@end

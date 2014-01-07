//
//  RBZUtils.m
//  Date Reminder
//
//  Created by robin on 13-12-23.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZUtils.h"

@implementation RBZUtils

+ (BOOL)onSameDay:(NSDate *)date1 anotherDate:(NSDate *)date2
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps1 = [gregorian components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date1];
    NSDateComponents *comps2 = [gregorian components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date2];
    if (comps1.day == comps2.day && comps1.month == comps2.month && comps1.year == comps2.year)
        return YES;
    return NO;
}

+ (NSDate *)beginningOfTomorrow
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    NSDate *tomorrow = [now dateByAddingTimeInterval:86400];
    NSDateComponents *comps = [gregorian components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:tomorrow];
    NSDate *beginning = [gregorian dateFromComponents:comps];
    return beginning;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)getReadableTimeInterval:(NSTimeInterval)interval
{
    int absInterval = abs((int)interval);
    NSInteger day = absInterval / 86400;
    NSInteger hour = (absInterval % 86400) / 3600;
    NSInteger minute = (absInterval % 3600) / 60;
    NSInteger sec = (absInterval % 60);
    if (day > 0) {
        return [NSString stringWithFormat:@"%dd%dh%dm%ds", day, hour, minute, sec];
    } else if (hour > 0) {
        return [NSString stringWithFormat:@"%dh%dm%ds", hour, minute, sec];
    } else if (minute > 0) {
        return [NSString stringWithFormat:@"%dm%ds", minute, sec];
    } else {
        return [NSString stringWithFormat:@"%ds", sec];
    }
}

@end

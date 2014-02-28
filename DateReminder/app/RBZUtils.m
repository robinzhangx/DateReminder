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

+ (UIImage *)imageWithColor:(UIColor *)color roundedCorner:(CGFloat)cornerRadius
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f + cornerRadius * 2, 1.0f + cornerRadius + 2);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (NSString *)getReadableTimeInterval:(NSTimeInterval)interval
{
    int absInterval = abs((int)interval);
    NSInteger day = absInterval / 86400;
    NSInteger hour = (absInterval % 86400) / 3600;
    NSInteger minute = (absInterval % 3600) / 60;
    NSInteger sec = (absInterval % 60);
    if (day > 0) {
        return [NSString stringWithFormat:@"%dd %dh", day, hour];
    } else if (hour > 0) {
        return [NSString stringWithFormat:@"%dh %dm", hour, minute];
    } else if (minute > 0) {
        return [NSString stringWithFormat:@"%dm %ds", minute, sec];
    } else {
        return [NSString stringWithFormat:@"%ds", sec];
    }
}

+ (void)roundedCornerMask:(UIView *)view corners:(UIRectCorner)corners radius:(CGFloat)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    view.layer.mask = maskLayer;
}

+ (void)dropShadow:(UIView *)view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    view.layer.shadowOpacity = 0.1f;
    view.layer.shadowPath = shadowPath.CGPath;
}

+ (void)dropShadow:(UIView *)view path:(UIBezierPath *)path
{
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    view.layer.shadowOpacity = 0.1f;
    view.layer.shadowPath = path.CGPath;
}

+ (void)removeDropShadow:(UIView *)view
{
    view.layer.shadowColor = nil;
    view.layer.shadowOpacity = 0.0;
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

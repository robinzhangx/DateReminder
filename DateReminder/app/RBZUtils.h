//
//  RBZUtils.h
//  Date Reminder
//
//  Created by robin on 13-12-23.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBZUtils : NSObject

+ (BOOL)onSameDay:(NSDate *)date1 anotherDate:(NSDate *)date2;
+ (NSDate *)beginningOfTomorrow;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color roundedCorner:(CGFloat)cornerRadius;
+ (NSString *)getReadableTimeInterval:(NSTimeInterval)interval;
+ (void)roundedCornerMask:(UIView *)view corners:(UIRectCorner)corners radius:(CGFloat)radius;
+ (void)dropShadow:(UIView *)view;
+ (void)dropShadow:(UIView *)view path:(UIBezierPath *)path;
+ (void)removeDropShadow:(UIView *)view;
+ (BOOL)has31th:(NSInteger)month;
+ (NSInteger)lastDayOfMonth:(NSInteger)month year:(NSInteger)year;
+ (NSInteger)lastDayOfNextMonth:(NSInteger)month year:(NSInteger)year;
+ (NSInteger)next31th:(NSInteger)month;
+ (BOOL)isLeapYear:(NSInteger)year;
+ (NSInteger)nextLeapYear:(NSInteger)year;

@end

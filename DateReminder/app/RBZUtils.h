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
+ (NSString *)getReadableTimeInterval:(NSTimeInterval)interval;

@end

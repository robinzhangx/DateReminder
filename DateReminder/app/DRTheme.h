//
//  DRTheme.h
//  DateReminder
//
//  Created by robin on 3/22/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRTheme : NSObject

@property UIColor *mainColor;
@property UIColor *highlightColor;  // 60% main color
@property UIColor *focusColor;      // 10% main color
@property UIColor *selectedColor;   // 40% main color
@property float cornerRadius;

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end

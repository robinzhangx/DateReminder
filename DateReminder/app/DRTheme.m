//
//  DRTheme.m
//  DateReminder
//
//  Created by robin on 3/22/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "DRTheme.h"

@implementation DRTheme

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    self = [super init];
    if (self) {
        self.mainColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.highlightColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.6];
        self.selectedColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.4];
        self.focusColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.1];
        self.cornerRadius = 3.0;
    }
    return self;
}

@end

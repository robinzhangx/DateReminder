//
//  RBZMonthlyPickerView.h
//  DateReminder
//
//  Created by robin on 2/19/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RBZMonthlyPickerView;

@protocol MonthlyPickerDelegate
- (void)monthlyPicker:(RBZMonthlyPickerView *)view didSelectDay:(NSInteger)day;
@end

@interface RBZMonthlyPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id<MonthlyPickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (readonly) NSInteger day;

- (void)selectDay:(NSInteger)day;

@end

//
//  RBZDatePickerView.h
//  DateReminder
//
//  Created by robin on 2/16/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RBZDatePickerView;

@protocol DatePickerDelegate
- (void)datePicker:(RBZDatePickerView *)view didSelectDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
@end

@interface RBZDatePickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id<DatePickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger year;

- (void)selectDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;

@end

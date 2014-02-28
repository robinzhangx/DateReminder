//
//  RBZYearlyPickerView.h
//  DateReminder
//
//  Created by robin on 2/20/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RBZYearlyPickerView;

@protocol YearlyPickerDelegate
- (void)yearlyPicker:(RBZYearlyPickerView *)view didSelectDay:(NSInteger)day month:(NSInteger)month;
@end

@interface RBZYearlyPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id<YearlyPickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;

- (void)selectDay:(NSInteger)day month:(NSInteger)month;

@end

//
//  RBZWeeklyPickerView.h
//  DateReminder
//
//  Created by robin on 2/19/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RBZWeeklyPickerView;

@protocol WeeklyPickerDelegate
- (void)weeklyPicker:(RBZWeeklyPickerView *)view didSelectWeekday:(NSInteger)weekday;
@end

@interface RBZWeeklyPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id<WeeklyPickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (readonly) NSInteger weekday;

- (void)selectWeekday:(NSInteger)weekday;

@end

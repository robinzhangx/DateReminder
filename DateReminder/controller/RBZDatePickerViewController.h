//
//  RBZDatePickerViewController.h
//  DateReminder
//
//  Created by robin on 2/16/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZDatePickerView.h"
#import "RBZWeeklyPickerView.h"
#import "RBZMonthlyPickerView.h"
#import "RBZYearlyPickerView.h"

@interface RBZDatePickerViewController : UIViewController <DatePickerDelegate, WeeklyPickerDelegate, MonthlyPickerDelegate, YearlyPickerDelegate>

@property NSNumber *type;
@property NSNumber *day;
@property NSNumber *weekday;
@property NSNumber *month;
@property NSNumber *year;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *weeklyButton;
@property (weak, nonatomic) IBOutlet UIButton *monthlyButton;
@property (weak, nonatomic) IBOutlet UIButton *yearlyButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@property (weak, nonatomic) IBOutlet UIView *pickerTypeHighlightView;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UIView *pickerTypeSeparatorView;

@end

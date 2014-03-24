//
//  RBZYearlyPickerView.m
//  DateReminder
//
//  Created by robin on 2/20/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZYearlyPickerView.h"
#import "RBZDateReminder.h"

@implementation RBZYearlyPickerView {
    NSArray *_monthTitles;
    NSMutableArray *_dayTitles;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.pickerView reloadAllComponents];
    _day = 1;
    _month = 1;
}

- (void)commonSetup
{
    [self populateTitleStrings];
}

- (void)populateTitleStrings
{
    NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
    _monthTitles = [formatter monthSymbols];
    _dayTitles = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 31; i++) {
        [_dayTitles addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

- (void)validateYearlyValue
{
    NSInteger month = [self.pickerView selectedRowInComponent:0] + 1;
    NSInteger day = [self.pickerView selectedRowInComponent:1] + 1;
    if (day == 31) {
        if (month == 2 || month == 4 || month == 6 || month == 9 || month == 11) {
            if (month == 2) {
                [self.pickerView selectRow:29 - 1 inComponent:1 animated:YES];
            } else {
                [self.pickerView selectRow:30 - 1 inComponent:1 animated:YES];
            }
        }
    } else if (day == 30) {
        if (month == 2) {
            [self.pickerView selectRow:29 - 1 inComponent:1 animated:YES];
        }
    } else if (day == 29) {
        if (month == 2) {
        }
    }
}

- (void)selectDay:(NSInteger)day month:(NSInteger)month
{
    if (month > 0 && month <= [_monthTitles count]) {
        _month = month;
        [self.pickerView selectRow:month - 1 inComponent:0 animated:YES];
    }
    if (day > 0 && day <= [_dayTitles count]) {
        [self.pickerView selectRow:day - 1 inComponent:1 animated:YES];
    }
    [self validateYearlyValue];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0: return [_monthTitles count];
        case 1: return [_dayTitles count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    switch (component) {
        case 0:
            if (!view) {
                UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 140.0, 40.0)];
                //[label setBackgroundColor:[UIColor blackColor]];
                [label setTextColor:[UIColor whiteColor]];
                [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:22.0]];
                [label setTextAlignment:NSTextAlignmentCenter];
                view = label;
            }
            [(UILabel *)view setText:_monthTitles[row]];
            break;
        case 1:
            if (!view) {
                UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 140.0, 40.0)];
                //[label setBackgroundColor:[UIColor blackColor]];
                [label setTextColor:[UIColor whiteColor]];
                [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:22.0]];
                [label setTextAlignment:NSTextAlignmentCenter];
                view = label;
            }
            [(UILabel *)view setText:_dayTitles[row]];
            break;
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self validateYearlyValue];
    _month = [self.pickerView selectedRowInComponent:0] + 1;
    _day = [self.pickerView selectedRowInComponent:1] + 1;
    [self.delegate yearlyPicker:self didSelectDay:_day month:_month];
}


@end

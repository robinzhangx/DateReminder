//
//  RBZWeeklyPickerView.m
//  DateReminder
//
//  Created by robin on 2/19/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZWeeklyPickerView.h"
#import "RBZDateReminder.h"

@implementation RBZWeeklyPickerView {
    UIColor *_mainColor;
    NSArray *_titleStrings;
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
    _weekday = 1;
}

- (void)commonSetup
{
    [self populateTitleStrings];
}

- (void)selectWeekday:(NSInteger)weekday
{
    if (weekday > 0 && weekday <= [_titleStrings count]) {
        _weekday = weekday;
        [self.pickerView selectRow:_weekday - 1 inComponent:0 animated:YES];
    }
}

- (void)populateTitleStrings
{
    NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
    _titleStrings = formatter.weekdaySymbols;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_titleStrings count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view) {
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 140.0, 40.0)];
        //[label setBackgroundColor:[UIColor blackColor]];
        [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:22.0]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        view = label;
    }
    [(UILabel *)view setText:_titleStrings[row]];
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _weekday = row + 1;
    [self.delegate weeklyPicker:self didSelectWeekday:row + 1];
}

@end

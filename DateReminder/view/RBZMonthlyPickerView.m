//
//  RBZMonthlyPickerView.m
//  DateReminder
//
//  Created by robin on 2/19/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZMonthlyPickerView.h"

@implementation RBZMonthlyPickerView {
    NSMutableArray *_titleStrings;
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
}

- (void)commonSetup
{
    [self populateTitleStrings];
}

- (void)populateTitleStrings
{
    _titleStrings = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 31; i++) {
        if (i == 1) {
            [_titleStrings addObject:@"1st"];
        } else if (i == 2) {
            [_titleStrings addObject:@"2nd"];
        } else if (i == 3) {
            [_titleStrings addObject:@"3rd"];
        } else if (i == 31) {
            [_titleStrings addObject:@"31th (last day of month)"];
        } else {
            [_titleStrings addObject:[NSString stringWithFormat:@"%dth", i]];
        }
    }
}

- (void)selectDay:(NSInteger)day
{
    if (day > 0 && day <= [_titleStrings count]) {
        _day = day;
        [self.pickerView selectRow:_day - 1 inComponent:0 animated:YES];
    }
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
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
        //[label setBackgroundColor:[UIColor blackColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:22.0]];
        [label setTextAlignment:NSTextAlignmentCenter];
        view = label;
    }
    [(UILabel *)view setText:_titleStrings[row]];
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _day = row + 1;
    [self.delegate monthlyPicker:self didSelectDay:row + 1];
}

@end

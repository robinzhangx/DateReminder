//
//  RBZDatePickerView.m
//  DateReminder
//
//  Created by robin on 2/16/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZDatePickerView.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"

@implementation RBZDatePickerView {
    NSCalendar *_calendar;
    NSInteger _currentYear;
    NSInteger _currentMonth;
    NSInteger _currentDay;
    UIColor *_mainColor;
    NSMutableArray *_dayValues;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    [self selectDate:[NSDate date]];
}

- (void)commonSetup
{
    _calendar = [[RBZDateReminder instance] defaultCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    _currentDay = comps.day;
    _currentMonth = comps.month;
    _currentYear = comps.year;
    [self populateDayComponent:0];
    _day = _currentDay;
    _month = _currentMonth;
    _year = _currentYear;
}

- (void)populateDayComponent:(NSInteger)row
{
    NSDate *d = [self getMonthYearDate:row];
    NSDateComponents *comps = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:d];
    NSInteger days = [RBZUtils lastDayOfMonth:comps.month year:comps.year];
    _dayValues = [[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
    formatter.dateFormat = @"EEE, dd";
    for (int i = 0; i < days; i++) {
        comps.day = i + 1;
        NSDate *d = [_calendar dateFromComponents:comps];
        NSString *str = [formatter stringFromDate:d];
        if (row == 0 && comps.day == _currentDay)
            str = [NSString stringWithFormat:@"%@ (Today)", str];
        [_dayValues addObject:str];
    }
}

- (NSString *)getMonthYearRowString:(NSInteger)row
{
    NSDate *d = [self getMonthYearDate:row];
    NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
    formatter.dateFormat = @"YYYY MMM";
    return [formatter stringFromDate:d];
}

- (NSDate *)getMonthYearDate:(NSInteger)row
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = _currentYear;
    comps.month = _currentMonth;
    NSDate *d = [_calendar dateFromComponents:comps];
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.month = row;
    d = [_calendar dateByAddingComponents:add toDate:d options:0];
    return d;
}

- (void)selectDate:(NSDate *)date
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = _currentYear;
    comps.month = _currentMonth;
    NSDate *d = [_calendar dateFromComponents:comps];
    NSDateComponents *diff = [_calendar components:NSMonthCalendarUnit fromDate:d toDate:date options:0];
    NSInteger row = diff.month;
    if (row >= 0 && row < 600) {
        [self.pickerView selectRow:row inComponent:0 animated:NO];
        [self populateDayComponent:row];
        [self.pickerView reloadComponent:1];
        comps = [_calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        [self.pickerView selectRow:comps.day - 1 inComponent:1 animated:NO];
        _day = comps.day;
        _month = comps.month;
        _year = comps.year;
        [self.delegate datePicker:self didSelectDay:comps.day month:comps.month year:comps.year];
    }
}

- (void)selectDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = year;
    comps.month = month;
    comps.day = day;
    NSDate *d = [_calendar dateFromComponents:comps];
    [self selectDate:d];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0: return 600;
        case 1: return [_dayValues count];
    }
    return 0;
}

static NSString *_pickerLabelFont = @"AvenirNextCondensed-Regular";
static float _pickerLabelFontSize = 22.0;

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    switch (component) {
        case 0:
            if (!view) {
                UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 130.0, 40.0)];
                //[label setBackgroundColor:[UIColor blackColor]];
                [label setTextColor:[UIColor whiteColor]];
                [label setTextAlignment:NSTextAlignmentRight];
                [label setFont:[UIFont fontWithName:_pickerLabelFont size:_pickerLabelFontSize]];
                view = label;
            }
            [(UILabel *)view setText:[self getMonthYearRowString:row]];
            break;
        case 1:
            if (!view) {
                UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 130.0, 40.0)];
                //[label setBackgroundColor:[UIColor blackColor]];
                [label setTextColor:[UIColor whiteColor]];
                [label setFont:[UIFont fontWithName:_pickerLabelFont size:_pickerLabelFontSize]];
                view = label;
            }
            [(UILabel *)view setText:_dayValues[row]];
            break;
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            [self populateDayComponent:row];
            [self.pickerView reloadComponent:1];
            if (row == 0) {
                _day = _currentDay;
                [self.pickerView selectRow:_currentDay - 1 inComponent:1 animated:YES];
            } else {
                _day = 1;
                [self.pickerView selectRow:0 inComponent:1 animated:YES];
            }
            NSDate *d = [self getMonthYearDate:row];
            NSDateComponents *comps = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:d];
            _month = comps.month;
            _year = comps.year;
            [self.delegate datePicker:self didSelectDay:_day month:comps.month year:comps.year];
            break;
        }
        case 1: {
            int monthRow = [self.pickerView selectedRowInComponent:0];
            NSDate *d = [self getMonthYearDate:monthRow];
            NSDateComponents *comps = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:d];
            _day = row + 1;
            [self.delegate datePicker:self didSelectDay:row + 1 month:comps.month year:comps.year];
        }
    }
}

@end

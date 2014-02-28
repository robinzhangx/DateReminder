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
    _weekday = 1;
}

- (void)commonSetup
{
    _mainColor = [UIColor colorWithRed:251.0/255.0 green:119.0/255.0 blue:52.0/255.0 alpha:1.0];
    [self populateTitleStrings];
}

- (void)selectWeekday:(NSInteger)weekday
{
    if (weekday > 0 && weekday <= [_titleStrings count]) {
        _weekday = weekday;
        [self.pickerView selectRow:_weekday - 1 inComponent:0 animated:YES];
    }
}

static NSString *_pickerLabelFont = @"AvenirNextCondensed-Regular";
static float _pickerLabelFontSize = 22.0;

- (void)populateTitleStrings
{
    _titleStrings = [[NSMutableArray alloc] init];
    NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
    NSArray *symbols = formatter.weekdaySymbols;
    UIFont *font = [UIFont fontWithName:_pickerLabelFont size:_pickerLabelFontSize];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    for (NSString *str in symbols) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDic];
        int len = [str length];
        [attrStr addAttribute:NSForegroundColorAttributeName value:_mainColor range:NSMakeRange(0, 1)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(1, len - 1)];
        [_titleStrings addObject:attrStr];
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
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 140.0, 40.0)];
        //[label setBackgroundColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        view = label;
    }
    [(UILabel *)view setAttributedText:_titleStrings[row]];
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _weekday = row + 1;
    [self.delegate weeklyPicker:self didSelectWeekday:row + 1];
}

@end

//
//  RBZDateValueViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-22.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZDateValueViewController.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZDateValueViewController ()

@property NSCalendar *calendar;
@property NSArray *monthSymbols;

@property NSInteger components;
@property NSArray *values;

@end

static NSString *const GA_VC_DATE_VALUE = @"Date Value Picker View";

@implementation RBZDateValueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.setButton.layer.cornerRadius = 2.0;
    
    UIColor *highlightColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    UIImage *highlightImage = [RBZUtils imageWithColor:highlightColor];
    [self.setButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];

    switch ([self.type integerValue]) {
        case RBZEventWeekly:
            [self populateWeeklyValues];
            self.typeLabel.text = @"Every week on";
            break;
        case RBZEventMonthly:
            [self populateMonthlyValues];
            self.typeLabel.text = @"Every month on";
            break;
        case RBZEventYearly:
            [self populateYearlyValues];
            self.typeLabel.text = @"Every year on";
            break;
    }
    [self.pickerView reloadAllComponents];
    [self selectEventDateValue];
    [self updateSetButtonTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [GoogleAnalyticsHelper trackScreen:GA_VC_DATE_VALUE];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    switch ([self.type integerValue]) {
        case RBZEventWeekly:
            self.weekday = [NSNumber numberWithInteger:[self.pickerView selectedRowInComponent:0] + 1];
            break;
        case RBZEventMonthly:
            self.day = [NSNumber numberWithInteger:[self.pickerView selectedRowInComponent:0] + 1];
            break;
        case RBZEventYearly:
            self.month = [NSNumber numberWithInteger:[self.pickerView selectedRowInComponent:0] + 1];
            self.day = [NSNumber numberWithInteger:[self.pickerView selectedRowInComponent:1] + 1];
            break;
    }
}

- (void)populateWeeklyValues
{
    self.components = 1;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:self.calendar];
    self.values = @[[formatter weekdaySymbols]];
}

- (void)populateMonthlyValues
{
    self.components = 1;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 31; i++) {
        if (i == 1) {
            [array addObject:@"1st"];
        } else if (i == 2) {
            [array addObject:@"2nd"];
        } else if (i == 3) {
            [array addObject:@"3rd"];
        } else if (i == 31) {
            [array addObject:@"31th (last day of month)"];
        } else {
            [array addObject:[NSString stringWithFormat:@"%dth", i]];
        }
    }
    self.values = @[array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:self.calendar];
    self.monthSymbols = [formatter monthSymbols];
}

- (void)selectEventDateValue
{
    NSDate *now = [[NSDate alloc] init];
    NSDateComponents *comps = [self.calendar components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit fromDate:now];
    switch ([self.type integerValue]) {
        case RBZEventWeekly:
            if (self.weekday)
                [self.pickerView selectRow:[self.weekday integerValue] - 1 inComponent:0 animated:YES];
            else
                [self.pickerView selectRow:comps.weekday - 1 inComponent:0 animated:YES];
            break;
        case RBZEventMonthly:
            if (self.day)
                [self.pickerView selectRow:[self.day integerValue] - 1 inComponent:0 animated:YES];
            else
                [self.pickerView selectRow:comps.day - 1 inComponent:0 animated:YES];
            break;
        case RBZEventYearly:
            if (self.day && self.month) {
                [self.pickerView selectRow:[self.month integerValue] - 1 inComponent:0 animated:YES];
                [self.pickerView selectRow:[self.day integerValue] - 1 inComponent:1 animated:YES];
            } else {
                [self.pickerView selectRow:comps.month - 1 inComponent:0 animated:YES];
                [self.pickerView selectRow:comps.day - 1 inComponent:1 animated:YES];
            }
            break;
    }
}

- (void)populateYearlyValues
{
    self.components = 2;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:self.calendar];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 31; i++) {
        [array addObject:[NSString stringWithFormat:@"%d", i]];
    }
    self.values = @[[formatter monthSymbols], array];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.components;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.values[component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.values[component] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self validateDateValue];
    [self updateSetButtonTitle];
}

- (void)updateSetButtonTitle
{
    NSString *valueStr;
    switch ([self.type integerValue]) {
        case RBZEventWeekly: {
            valueStr = self.values[0][[self.pickerView selectedRowInComponent:0]];
            break;
        }
        case RBZEventMonthly: {
            NSInteger idx = [self.pickerView selectedRowInComponent:0];
            if (idx == 30) {
                valueStr = @"last day of month";
            } else {
                valueStr = self.values[0][idx];
            }
            break;
        }
        case RBZEventYearly: {
            NSString *monthStr = self.values[0][[self.pickerView selectedRowInComponent:0]];
            NSString *dayStr = self.values[1][[self.pickerView selectedRowInComponent:1]];
            valueStr = [NSString stringWithFormat:@"%@ %@", monthStr, dayStr];
            break;
        }
    }
    [self.setButton setTitle:[NSString stringWithFormat:@"Set %@", valueStr] forState:UIControlStateNormal];
}

- (void)validateDateValue
{
    switch ([self.type integerValue]) {
        case RBZEventMonthly:
            break;
        case RBZEventYearly:
            [self validateYearlyValue];
            break;
    }
}

- (void)validateMonthlyValue:(NSInteger)day
{
    
}

- (void)validateYearlyValue
{
    //self.hintLabel.text = @"";
    NSInteger month = [self.pickerView selectedRowInComponent:0] + 1;
    NSInteger day = [self.pickerView selectedRowInComponent:1] + 1;
    if (day == 31) {
        if (month == 2 || month == 4 || month == 6 || month == 9 || month == 11) {
            if (month == 2) {
                [self.pickerView selectRow:29 - 1 inComponent:1 animated:YES];
                //self.hintLabel.text = @"Only on leap year";
            } else {
                [self.pickerView selectRow:30 - 1 inComponent:1 animated:YES];
            }
        }
    } else if (day == 30) {
        if (month == 2) {
            [self.pickerView selectRow:29 - 1 inComponent:1 animated:YES];
            //self.hintLabel.text = @"Only on leap year";
        }
    } else if (day == 29) {
        if (month == 2) {
            //self.hintLabel.text = @"Only on leap year";
        }
    }
}

@end

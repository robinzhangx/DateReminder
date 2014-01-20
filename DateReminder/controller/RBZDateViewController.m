//
//  RBZDateViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-22.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZDateViewController.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZDateViewController ()

@property NSCalendar *calendar;
@property UIDatePicker *datePicker;

@end

static NSString *const GA_VC_DATE_VIEW = @"Date Picker View";

@implementation RBZDateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.datePicker = [RBZDateReminder instance].datePicker;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.pickerContainer addSubview:self.datePicker];
    [self.datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *viewDic = @{ @"picker" : self.datePicker };
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[picker]|" options:0 metrics:nil views:viewDic];
    [self.pickerContainer addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[picker]|" options:0 metrics:nil views:viewDic];
    [self.pickerContainer addConstraints:constraints];
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.datePicker.calendar = self.calendar;
    self.setButton.layer.cornerRadius = 2.0;
    
    UIColor *highlightColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    UIImage *highlightImage = [RBZUtils imageWithColor:highlightColor];
    [self.setButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];

    [self setDefaultEventDate];
    [self updateSetButtonTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [GoogleAnalyticsHelper trackScreen:GA_VC_DATE_VIEW];
    [self.datePicker addTarget:self
                        action:@selector(onPickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.datePicker removeTarget:self
                           action:@selector(onPickerValueChanged:)
                 forControlEvents:UIControlEventValueChanged];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDate *date = self.datePicker.date;
    NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                               fromDate:date];
    self.day = [NSNumber numberWithInteger:comps.day];
    self.month = [NSNumber numberWithInteger:comps.month];
    self.year = [NSNumber numberWithInteger:comps.year];
}

- (IBAction)onPickerValueChanged:(id)sender
{
    [self updateSetButtonTitle];
}

- (void)setDefaultEventDate
{
    if (self.day && self.month && self.year) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.day = [self.day integerValue];
        comps.month = [self.month integerValue];
        comps.year = [self.year integerValue];
        NSDate *d = [self.calendar dateFromComponents:comps];
        [self.datePicker setDate:d animated:NO];
    } else {
        [self.datePicker setDate:[NSDate date] animated:NO];
    }
}

- (void)updateSetButtonTitle
{
    NSDate *date = self.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *str = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"EE"];
    str = [NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:date], str];
    [self.setButton setTitle:[NSString stringWithFormat:@"Set %@", str] forState:UIControlStateNormal];
}

@end

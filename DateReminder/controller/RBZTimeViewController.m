//
//  RBZTimeViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-20.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZTimeViewController.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"

@interface RBZTimeViewController ()

@property NSCalendar *calendar;
@property UIDatePicker *timePicker;

@end

static NSString *const FLURRY_VC_TIME_VIEW = @"vc_time_view";

@implementation RBZTimeViewController

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
    
    self.timePicker = [RBZDateReminder instance].datePicker;
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    [self.pickerContainer addSubview:self.timePicker];
    [self.timePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *viewDic = @{ @"picker" : self.timePicker };
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[picker]|" options:0 metrics:nil views:viewDic];
    [self.pickerContainer addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[picker]|" options:0 metrics:nil views:viewDic];
    [self.pickerContainer addConstraints:constraints];
    
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.timePicker.calendar = self.calendar;
    self.setButton.layer.cornerRadius = 2.0;
    
    UIColor *highlightColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    UIImage *highlightImage = [RBZUtils imageWithColor:highlightColor];
    [self.setButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];

    if (self.hour && self.minute) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setHour:[self.hour integerValue]];
        [comps setMinute:[self.minute integerValue]];
        NSDate *date = [self.calendar dateFromComponents:comps];
        [self.timePicker setDate:date animated:NO];
    } else {
        [self.timePicker setDate:[NSDate date] animated:NO];
    }
    
    [self updateSetButtonTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [Flurry logEvent:FLURRY_VC_TIME_VIEW timed:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [Flurry endTimedEvent:FLURRY_VC_TIME_VIEW withParameters:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.timePicker addTarget:self
                        action:@selector(onPickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.timePicker removeTarget:self
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
    NSDate *date = self.timePicker.date;
    NSDateComponents *comps = [self.calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                               fromDate:date];
    self.hour = [NSNumber numberWithInteger:comps.hour];
    self.minute = [NSNumber numberWithInteger:comps.minute];
}

- (IBAction)onPickerValueChanged:(id)sender
{
    [self updateSetButtonTitle];
}

- (void)updateSetButtonTitle
{
    NSDate *date = self.timePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *str = [dateFormatter stringFromDate:date];
    [self.setButton setTitle:[NSString stringWithFormat:@"Set %@", str] forState:UIControlStateNormal];
}

@end

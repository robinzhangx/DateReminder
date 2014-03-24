//
//  RBZTimePickerViewController.m
//  DateReminder
//
//  Created by robin on 2/15/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "RBZTimePickerViewController.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZTimePickerViewController ()

@end

@implementation RBZTimePickerViewController {
    DRTheme *_theme;
    NSCalendar *_calendar;
}

static NSString *const GA_VC_TIME_PICKER_VIEW = @"Time Picker View";

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
    [self commonSetup];
    [self.cancelButton addTarget:self action:@selector(onCancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self setupHourButtons];
    [self setupMinuteButtons];
    [self setupAmPmButton];
    [self setupPlusButtons];
    
    if (self.hour && self.minute) {
        NSDate *date = [self roundup5Minutes:[self.minute integerValue] hour:[self.hour integerValue]];
        NSDateComponents *comps = [_calendar components:NSMinuteCalendarUnit fromDate:date];
        self.minute = [NSNumber numberWithInteger:comps.minute];
    } else {
        NSDate *date = [self roundup5Minutes:[NSDate date]];
        NSDateComponents *comps = [_calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
        self.hour = [NSNumber numberWithInteger:comps.hour];
        self.minute = [NSNumber numberWithInteger:comps.minute];
    }
    [self updateTimeLabel];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [RBZUtils dropShadow:self.cancelButton];
    [RBZUtils dropShadow:self.setButton];
    
    UIButton *hourButton = [self getHourButton:[self.hour integerValue]];
    UIButton *minuteButton = [self getMinute10Button:[self.minute integerValue]];
    if ([self hasMinute05Button:[self.minute integerValue]]) {
        self.m05Highlight.hidden = NO;
    } else {
        self.m05Highlight.hidden = YES;
    }
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.hourHighlight.frame = hourButton.frame;
                         self.minuteHighlight.frame = minuteButton.frame;
                         if ([self isAM:[self.hour integerValue]]) {
                             self.ampmHighlight.frame = self.amButton.frame;
                         } else {
                             self.ampmHighlight.frame = self.pmButton.frame;
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleAnalyticsHelper trackScreen:GA_VC_TIME_PICKER_VIEW];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonSetup
{
    _theme = [RBZDateReminder instance].theme;
    _calendar = [[RBZDateReminder instance] defaultCalendar];
    self.setButton.backgroundColor = _theme.mainColor;
    self.timeLabel.textColor = _theme.mainColor;
    self.hourHighlight.backgroundColor = _theme.selectedColor;
    self.minuteHighlight.backgroundColor = _theme.selectedColor;
    self.m05Highlight.backgroundColor = _theme.selectedColor;
    self.ampmHighlight.backgroundColor = _theme.selectedColor;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.setButton.layer.cornerRadius = 3.0;
}

- (void)updateTimeLabel
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:[self.hour integerValue]];
    [comps setMinute:[self.minute integerValue]];
    NSDate *date = [_calendar dateFromComponents:comps];
    NSDateFormatter *formater = [[RBZDateReminder instance] getLocalizedDateFormatter];
    [formater setTimeStyle:NSDateFormatterShortStyle];
    NSString *str = [formater stringFromDate:date];
    self.timeLabel.text = str;
}

- (void)updateHour:(NSInteger)hour
{
    UIButton *current = [self getHourButton:[self.hour integerValue]];
    UIButton *target = [self getHourButton:hour];
    if (current != target) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.hourHighlight.frame = target.frame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    if ([self isAM:hour] ^ [self isAM:[self.hour integerValue]]) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             if ([self isAM:hour])
                                 self.ampmHighlight.frame = self.amButton.frame;
                             else
                                 self.ampmHighlight.frame = self.pmButton.frame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    self.hour = [NSNumber numberWithInteger:hour];
    [self updateTimeLabel];
}

- (void)updateMinute:(NSInteger)minute
{
    UIButton *current = [self getMinute10Button:[self.minute integerValue]];
    UIButton *target = [self getMinute10Button:minute];
    if (current != target) {
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.minuteHighlight.frame = target.frame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    if ([self hasMinute05Button:minute]) {
        self.m05Highlight.hidden = NO;
    } else {
        self.m05Highlight.hidden = YES;
    }
    self.minute = [NSNumber numberWithInteger:minute];
    [self updateTimeLabel];
}

- (IBAction)onCancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Buttons

- (void)setupHourButtons
{
    for (int i = 1; i <= 12; i++) {
        UIButton *button = [self getHourButton:i];
        button.tag = i;
        [button setAttributedTitle:[self getHourString:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hourButtonTapped:) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)setupMinuteButtons
{
    for (int i = 0; i <= 50; i = i + 10) {
        UIButton *button = [self getMinute10Button:i];
        button.tag = i;
        [button setAttributedTitle:[self getMinuteString:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(minuteButtonTapped:) forControlEvents:UIControlEventTouchDown];
    }
    self.m05Button.tag = 5;
    [self.m05Button setAttributedTitle:[self getMinuteString:5] forState:UIControlStateNormal];
    [self.m05Button addTarget:self action:@selector(minuteButtonTapped:) forControlEvents:UIControlEventTouchDown];
}

- (void)setupAmPmButton
{
    [self.amButton setTitleColor:_theme.mainColor forState:UIControlStateNormal];
    [self.amButton addTarget:self action:@selector(amButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.pmButton setTitleColor:_theme.mainColor forState:UIControlStateNormal];
    [self.pmButton addTarget:self action:@selector(pmButtonTapped:) forControlEvents:UIControlEventTouchDown];
}

- (void)setupPlusButtons
{
    self.plus5mButton.tag = 5;
    self.plus10mButton.tag = 10;
    self.plus30mButton.tag = 30;
    self.plus1hButton.tag = 60;
    
    [self.plus5mButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.plus10mButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.plus30mButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.plus1hButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchDown];
}

static NSString *_buttonLabelFont = @"AvenirNextCondensed-Regular";
static float _buttonLabelFontSize = 20.0;

- (NSAttributedString *)getHourString:(NSInteger)hour
{
    UIFont *font = [UIFont fontWithName:_buttonLabelFont size:_buttonLabelFontSize];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSString *str = [NSString stringWithFormat:@"%d:00", hour];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDic];
    int len = [str length];
    int initials = (hour >= 10 ? 3 : 2);
    [attrStr addAttribute:NSForegroundColorAttributeName value:_theme.mainColor range:NSMakeRange(0, initials)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(initials, len - initials)];
    return attrStr;
}

- (NSAttributedString *)getMinuteString:(NSInteger)minute
{
    UIFont *font = [UIFont fontWithName:_buttonLabelFont size:_buttonLabelFontSize];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSString *str = [NSString stringWithFormat:@":%02d", minute];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDic];
    int len = [str length];
    int initials = (minute == 5 ? 2 : 1);
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, initials)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:_theme.mainColor range:NSMakeRange(initials, len - initials)];
    return attrStr;
}

- (IBAction)hourButtonTapped:(UIButton *)sender
{
    [self playTapSound];
    NSInteger h;
    if ([self.hour integerValue] < 12) {
        h = sender.tag % 12;
    } else {
        h = sender.tag % 12 + 12;
    }
    [self updateHour:h];
}

- (IBAction)minuteButtonTapped:(UIButton *)sender
{
    [self playTapSound];
    if (sender.tag == 5) {
        NSInteger m = [self.minute integerValue];
        if ([self hasMinute05Button:m])
            m = m - m % 10;
        else
            m = m - m % 10 + 5;
        [self updateMinute:m];
    } else {
        [self updateMinute:sender.tag];
    }
}

- (IBAction)amButtonTapped:(UIButton *)sender
{
    [self playTapSound];
    NSInteger h = [self.hour integerValue];
    if (h >= 12) {
        [self updateHour:(h - 12)];
    }
}

- (IBAction)pmButtonTapped:(UIButton *)sender
{
    [self playTapSound];
    NSInteger h = [self.hour integerValue];
    if (h < 12) {
        [self updateHour:(h + 12)];
    }
}

- (IBAction)plusButtonTapped:(UIButton *)sender
{
    [self playTapSound];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.hour = [self.hour integerValue];
    comps.minute = [self.minute integerValue];
    NSDate *date = [_calendar dateFromComponents:comps];
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.minute = sender.tag;
    date = [_calendar dateByAddingComponents:add toDate:date options:0];
    comps = [_calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
    [self updateHour:comps.hour];
    [self updateMinute:comps.minute];
}

- (UIButton *)getHourButton:(NSInteger)hour
{
    switch (hour % 12) {
        case 0: return self.h12Button;
        case 1: return self.h1Button;
        case 2: return self.h2Button;
        case 3: return self.h3Button;
        case 4: return self.h4Button;
        case 5: return self.h5Button;
        case 6: return self.h6Button;
        case 7: return self.h7Button;
        case 8: return self.h8Button;
        case 9: return self.h9Button;
        case 10: return self.h10Button;
        case 11: return self.h11Button;
    }
    return nil;
}

- (UIButton *)getMinute10Button:(NSInteger)minute
{
    switch (minute / 10) {
        case 0: return self.m00Button;
        case 1: return self.m10Button;
        case 2: return self.m20Button;
        case 3: return self.m30Button;
        case 4: return self.m40Button;
        case 5: return self.m50Button;
    }
    return nil;
}

#pragma mark - Helper Functions

- (void)playTapSound
{
    AudioServicesPlaySystemSound(1105);
}

- (NSDate *)roundup5Minutes:(NSDate *)date
{
    NSDateComponents *comps = [_calendar components:NSMinuteCalendarUnit fromDate:date];
    int addMinutes = (5 - comps.minute % 5) % 5;
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.minute = addMinutes;
    return [_calendar dateByAddingComponents:add toDate:date options:0];
}

- (NSDate *)roundup5Minutes:(NSInteger)minute hour:(NSInteger)hour
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.minute = minute;
    comps.hour = hour;
    NSDate *date = [_calendar dateFromComponents:comps];
    int addMinutes = (5 - minute % 5) % 5;
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.minute = addMinutes;
    return [_calendar dateByAddingComponents:add toDate:date options:0];
}

- (BOOL)hasMinute05Button:(NSInteger)minute
{
    if (minute % 10 >= 5)
        return YES;
    else
        return NO;
}

- (BOOL)isAM:(NSInteger)hour
{
    return hour < 12;
}

@end

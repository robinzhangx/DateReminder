//
//  RBZDatePickerViewController.m
//  DateReminder
//
//  Created by robin on 2/16/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZDatePickerViewController.h"
#import "RBZDateReminder.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZDatePickerViewController ()

@end

@implementation RBZDatePickerViewController {
    DRTheme *_theme;
    BOOL _pickerAnimating;
    int _pickerShown;
}

static NSString *const GA_VC_DATE_PICKER_VIEW = @"Date Picker View";

static const int kPickerTypeDate = 0;
static const int kPickerTypeWeekly = 1;
static const int kPickerTypeMonthly = 2;
static const int kPickerTypeYearly = 3;

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
    [self setupTypeButtons];
    [self.cancelButton addTarget:self action:@selector(onCancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    if (self.type) {
        switch ([self.type integerValue]) {
            case RBZEventOnce: [self displayPickerView:kPickerTypeDate]; break;
            case RBZEventDaily: [self displayPickerView:kPickerTypeDate]; break;
            case RBZEventWeekly: [self displayPickerView:kPickerTypeWeekly]; break;
            case RBZEventMonthly: [self displayPickerView:kPickerTypeMonthly]; break;
            case RBZEventYearly: [self displayPickerView:kPickerTypeYearly]; break;
        }
    } else {
        [self displayPickerView:kPickerTypeDate];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updatePickerHighlight:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleAnalyticsHelper trackScreen:GA_VC_DATE_PICKER_VIEW];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonSetup
{
    _theme = [RBZDateReminder instance].theme;
    _pickerShown = -1;
    _pickerAnimating = NO;
    self.setButton.backgroundColor = _theme.mainColor;
    self.pickerTypeHighlightView.backgroundColor = _theme.mainColor;
    self.pickerTypeSeparatorView.backgroundColor = _theme.mainColor;
    self.dateLabel.textColor = _theme.mainColor;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.setButton.layer.cornerRadius = 3.0;
}

- (void)setupTypeButtons
{
    self.dateButton.tag = kPickerTypeDate;
    [self.dateButton addTarget:self action:@selector(onTypeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.weeklyButton.tag = kPickerTypeWeekly;
    [self.weeklyButton addTarget:self action:@selector(onTypeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.weeklyButton setAttributedTitle:[self getPickerTypeString:kPickerTypeWeekly] forState:UIControlStateNormal];
    self.monthlyButton.tag = kPickerTypeMonthly;
    [self.monthlyButton addTarget:self action:@selector(onTypeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.monthlyButton setAttributedTitle:[self getPickerTypeString:kPickerTypeMonthly] forState:UIControlStateNormal];
    self.yearlyButton.tag = kPickerTypeYearly;
    [self.yearlyButton addTarget:self action:@selector(onTypeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.yearlyButton setAttributedTitle:[self getPickerTypeString:kPickerTypeYearly] forState:UIControlStateNormal];
}

static NSString *_buttonLabelFont = @"AvenirNextCondensed-Regular";
static float _buttonLabelFontSize = 20.0;

- (NSAttributedString *)getPickerTypeString:(int)type
{
    UIFont *font = [UIFont fontWithName:_buttonLabelFont size:_buttonLabelFontSize];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSString *str;
    switch (type) {
        case kPickerTypeWeekly: str = @"Weekly"; break;
        case kPickerTypeMonthly: str = @"Monthly"; break;
        case kPickerTypeYearly: str = @"Yearly"; break;
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDic];
    int len = [str length];
    [attrStr addAttribute:NSForegroundColorAttributeName value:_theme.mainColor range:NSMakeRange(0, 1)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(1, len - 1)];
    return attrStr;
}

- (void)updateDateLabel:(UIView *)pickerView
{
    switch (_pickerShown) {
        case kPickerTypeDate: {
            if ([pickerView isKindOfClass:[RBZDatePickerView class]]) {
                RBZDatePickerView *picker = (RBZDatePickerView *)pickerView;
                self.type = [NSNumber numberWithInteger:RBZEventOnce];
                self.day = [NSNumber numberWithInteger:picker.day];
                self.month = [NSNumber numberWithInteger:picker.month];
                self.year = [NSNumber numberWithInteger:picker.year];
                
                NSCalendar *calendar = [[RBZDateReminder instance] defaultCalendar];
                NSDateFormatter *formatter = [[RBZDateReminder instance] getLocalizedDateFormatter];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                comps.day = picker.day;
                comps.month = picker.month;
                comps.year = picker.year;
                NSDate *d = [calendar dateFromComponents:comps];
                self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:48.0];
                self.dateLabel.text = [formatter stringFromDate:d];
            }
            break;
        }
        case kPickerTypeWeekly: {
            if ([pickerView isKindOfClass:[RBZWeeklyPickerView class]]) {
                RBZWeeklyPickerView *picker = (RBZWeeklyPickerView *)pickerView;
                self.type = [NSNumber numberWithInteger:RBZEventWeekly];
                self.weekday = [NSNumber numberWithInteger:picker.weekday];
                self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:60.0];
                self.dateLabel.text = [EventDate getWeeklyValueString:self.weekday];
            }
            break;
        }
        case kPickerTypeMonthly: {
            if ([pickerView isKindOfClass:[RBZMonthlyPickerView class]]) {
                RBZMonthlyPickerView *picker = (RBZMonthlyPickerView *)pickerView;
                self.type = [NSNumber numberWithInteger:RBZEventMonthly];
                self.day = [NSNumber numberWithInteger:picker.day];
                self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:60.0];
                self.dateLabel.text = [EventDate getMonthlyValueString:self.day];
            }
            break;
        }
        case kPickerTypeYearly: {
            if ([pickerView isKindOfClass:[RBZYearlyPickerView class]]) {
                RBZYearlyPickerView *picker = (RBZYearlyPickerView *)pickerView;
                self.type = [NSNumber numberWithInteger:RBZEventYearly];
                self.day = [NSNumber numberWithInteger:picker.day];
                self.month = [NSNumber numberWithInteger:picker.month];
                self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:60.0];
                self.dateLabel.text = [EventDate getYearlyValueString:self.day
                                                                month:self.month];
            }
            break;
        }
    }
}

- (IBAction)onCancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTypeButtonTapped:(UIButton *)sender
{
    if (_pickerAnimating)
        return;
    if (_pickerShown != sender.tag) {
        [self displayPickerView:sender.tag];
    }
}

#pragma mark - Picker Loader

- (UIView *)loadPickerView:(NSInteger)type
{
    switch (type) {
        case kPickerTypeDate: {
            NSArray *pickerViews = [[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil];
            RBZDatePickerView *picker = pickerViews[0];
            picker.delegate = self;
            return picker;
        }
        case kPickerTypeWeekly: {
            NSArray *pickerViews = [[NSBundle mainBundle] loadNibNamed:@"WeeklyPickerView" owner:self options:nil];
            RBZWeeklyPickerView *picker = pickerViews[0];
            picker.delegate = self;
            return picker;
        }
        case kPickerTypeMonthly: {
            NSArray *pickerViews = [[NSBundle mainBundle] loadNibNamed:@"MonthlyPickerView" owner:self options:nil];
            RBZMonthlyPickerView *picker = pickerViews[0];
            picker.delegate = self;
            return picker;
        }
        case kPickerTypeYearly: {
            NSArray *pickerViews = [[NSBundle mainBundle] loadNibNamed:@"YearlyPickerView" owner:self options:nil];
            RBZYearlyPickerView *picker = pickerViews[0];
            picker.delegate = self;
            return picker;
        }
    }
    return nil;
}

- (void)displayPickerView:(NSInteger)type
{
    _pickerAnimating = YES;
    _pickerShown = type;
    self.dateLabel.text = @"";
    UIView *view = [self loadPickerView:type];
    if ([self.pickerContainerView.subviews count] > 0) {
        UIView *old = self.pickerContainerView.subviews[0];
        view.alpha = 0.0;
        [self.pickerContainerView addSubview:view];
        [UIView animateWithDuration:.2
                         animations:^{
                             old.alpha = 0.0;
                             view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             [old removeFromSuperview];
                             _pickerAnimating = NO;
                         }];
        [self updatePickerHighlight:YES];
    } else {
        [self.pickerContainerView addSubview:view];
        _pickerAnimating = NO;
        [self updatePickerHighlight:YES];
    }
    [self updatePickerValue:view];
    [self updateDateLabel:view];
}

- (void)updatePickerValue:(UIView *)view
{
    if (self.type) {
        switch ([self.type integerValue]) {
            case RBZEventOnce: {
                if (_pickerShown == kPickerTypeDate) {
                    if (self.day && self.month && self.year) {
                        RBZDatePickerView *picker = (RBZDatePickerView *)view;
                        [picker selectDay:[self.day integerValue]
                                    month:[self.month integerValue]
                                     year:[self.year integerValue]];
                    }
                }
                break;
            }
            case RBZEventWeekly: {
                if (_pickerShown == kPickerTypeWeekly) {
                    if (self.weekday) {
                        RBZWeeklyPickerView *picker = (RBZWeeklyPickerView *)view;
                        [picker selectWeekday:[self.weekday integerValue]];
                    }
                }
                break;
            }
            case RBZEventMonthly: {
                if (_pickerShown == kPickerTypeMonthly) {
                    if (self.day) {
                        RBZMonthlyPickerView *picker = (RBZMonthlyPickerView *)view;
                        [picker selectDay:[self.day integerValue]];
                    }
                }
                break;
            }
            case RBZEventYearly: {
                if (_pickerShown == kPickerTypeYearly) {
                    if (self.day && self.month) {
                        RBZYearlyPickerView *picker = (RBZYearlyPickerView *)view;
                        [picker selectDay:[self.day integerValue]
                                    month:[self.month integerValue]];
                    }
                }
            }
        }
    }
}

- (void)updatePickerHighlight:(BOOL)animated
{
    UIView *destView;
    switch (_pickerShown) {
        case kPickerTypeDate: destView = self.dateButton; break;
        case kPickerTypeWeekly: destView = self.weeklyButton; break;
        case kPickerTypeMonthly: destView = self.monthlyButton; break;
        case kPickerTypeYearly: destView = self.yearlyButton; break;
    }
    CGRect curr = self.pickerTypeHighlightView.frame;
    CGRect dest = destView.frame;
    CGRect new = CGRectMake(dest.origin.x, curr.origin.y, curr.size.width, curr.size.height);
    if (animated) {
        [UIView animateWithDuration:.2 animations:^{ self.pickerTypeHighlightView.frame = new; }];
    } else {
        self.pickerTypeHighlightView.frame = new;
    }
}

#pragma mark - Picker Delegates

- (void)datePicker:(RBZDatePickerView *)view didSelectDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    [self updateDateLabel:view];
}

- (void)weeklyPicker:(RBZWeeklyPickerView *)view didSelectWeekday:(NSInteger)weekday
{
    [self updateDateLabel:view];
}

- (void)monthlyPicker:(RBZMonthlyPickerView *)view didSelectDay:(NSInteger)day
{
    [self updateDateLabel:view];
}

- (void)yearlyPicker:(RBZYearlyPickerView *)view didSelectDay:(NSInteger)day month:(NSInteger)month
{
    [self updateDateLabel:view];
}

@end

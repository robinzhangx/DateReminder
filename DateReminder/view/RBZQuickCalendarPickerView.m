//
//  RBZQuickCalendarPickerView.m
//  DateReminder
//
//  Created by robin on 2/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZQuickCalendarPickerView.h"
#import "RBZDateReminder.h"

@implementation RBZQuickCalendarPickerView {
    DRTheme *_theme;
    NSCalendar *_calendar;
    NSDate *_currentDate;
    NSInteger _startDateDelta;
    UIButton *_today;
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib
{
    for (int i = 0; i < 21; i++) {
        [self setupButton:i];
    }
    
    self.pickOtherButton.tag = -1;
    [self.pickOtherButton addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.dailyButton.tag = -2;
    [self.dailyButton addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.dailyButton setAttributedTitle:[self getDailyString] forState:UIControlStateNormal];
    
    self.saturdayLabel.textColor = _theme.mainColor;
    self.sundayLabel.textColor = _theme.mainColor;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    layer.cornerRadius = 15.0;
    layer.backgroundColor = _theme.mainColor.CGColor;
    [self.indicatorView.layer addSublayer:layer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorView.frame = _today.frame;
    CALayer *layer = (CALayer *)self.indicatorView.layer.sublayers[0];
    layer.position = _today.titleLabel.center;
    
    CGRect frame = self.separatorLine.frame;
    self.separatorLine.frame = CGRectMake(_today.frame.origin.x,
                                          frame.origin.y,
                                          frame.origin.x + frame.size.width - _today.frame.origin.x,
                                          frame.size.height);
}

- (void)commonSetup
{
    _theme = [RBZDateReminder instance].theme;
    _calendar = [[RBZDateReminder instance] defaultCalendar];
    _currentDate = [NSDate date];
    NSDateComponents *comps = [_calendar components:NSWeekdayCalendarUnit fromDate:_currentDate];
    _startDateDelta = -(comps.weekday - 1);
}

- (void)setupButton:(NSInteger)index
{
    NSInteger delta = _startDateDelta + index;
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.day = delta;
    NSDate *d = [_calendar dateByAddingComponents:add toDate:_currentDate options:0];
    NSDateComponents *comps = [_calendar components:NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:d];
    UIButton *button =  [self getButton:index];
    button.tag = index;
    [button setTitle:[NSString stringWithFormat:@"%d", comps.day] forState:UIControlStateNormal];
    if (comps.weekday == 1 || comps.weekday == 7) {
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    if (delta < 0) {
        [button setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateDisabled];
        button.enabled = NO;
    } else if (delta == 0) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _today = button;
    }
}

static NSString *_buttonLabelFont = @"AvenirNextCondensed-Regular";
static float _buttonLabelFontSize = 20.0;

- (NSAttributedString *)getDailyString
{
    UIFont *font = [UIFont fontWithName:_buttonLabelFont size:_buttonLabelFontSize];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSString *str = @"Daily";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDic];
    int len = [str length];
    [attrStr addAttribute:NSForegroundColorAttributeName value:_theme.mainColor range:NSMakeRange(0, 1)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(1, len - 1)];
    return attrStr;
}

- (UIButton *)getButton:(NSInteger)index
{
    switch (index) {
        case 0: return self.button00;
        case 1: return self.button01;
        case 2: return self.button02;
        case 3: return self.button03;
        case 4: return self.button04;
        case 5: return self.button05;
        case 6: return self.button06;
        case 7: return self.button10;
        case 8: return self.button11;
        case 9: return self.button12;
        case 10: return self.button13;
        case 11: return self.button14;
        case 12: return self.button15;
        case 13: return self.button16;
        case 14: return self.button20;
        case 15: return self.button21;
        case 16: return self.button22;
        case 17: return self.button23;
        case 18: return self.button24;
        case 19: return self.button25;
        case 20: return self.button26;
    }
    return nil;
}

- (IBAction)onButtonTapped:(UIButton *)sender
{
    if (sender.tag == -1) {
        [self.delegate quickCalendarPickerViewDidSelectPickOther:self];
        return;
    }
    if (sender.tag == -2) {
        [self.delegate quickCalendarPickerViewDidSelectDaily:self];
        return;
    }
    NSInteger delta = _startDateDelta + sender.tag;
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.day = delta;
    NSDate *d = [_calendar dateByAddingComponents:add toDate:_currentDate options:0];
    [self.delegate quickCalendarPickerView:self didSelectDate:d];
}

@end

//
//  RBZQuickReminderPickerView.m
//  DateReminder
//
//  Created by robin on 2/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZQuickReminderPickerView.h"
#import "RBZDateReminder.h"

@implementation RBZQuickReminderPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.button1m.tag = 1;
    [self.button1m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button1m setAttributedTitle:[self getReminderString:1] forState:UIControlStateNormal];
    self.button5m.tag = 5;
    [self.button5m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button5m setAttributedTitle:[self getReminderString:5] forState:UIControlStateNormal];
    self.button10m.tag = 10;
    [self.button10m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button10m setAttributedTitle:[self getReminderString:10] forState:UIControlStateNormal];
    self.button15m.tag = 15;
    [self.button15m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button15m setAttributedTitle:[self getReminderString:15] forState:UIControlStateNormal];
    self.button30m.tag = 30;
    [self.button30m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button30m setAttributedTitle:[self getReminderString:30] forState:UIControlStateNormal];
    self.button60m.tag = 60;
    [self.button60m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.button60m setAttributedTitle:[self getReminderString:60] forState:UIControlStateNormal];
    self.noReminderButton.tag = -1;
    [self.noReminderButton addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.noReminderButton setAttributedTitle:[self getReminderString:-1] forState:UIControlStateNormal];
}

static NSString *_buttonLabelFont = @"AvenirNextCondensed-Regular";
static float _buttonLabelFontSize = 20.0;

- (NSAttributedString *)getReminderString:(NSInteger)minutes
{
    UIFont *font = [UIFont fontWithName:_buttonLabelFont size:_buttonLabelFontSize];
    NSDictionary *attrsDic = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSString *str;
    int initials;
    if (minutes <= 0) {
        str = @"No reminder";
        initials = 1;
    } else if (minutes < 60) {
        str = [NSString stringWithFormat:@"%dmin", minutes];
        initials = (minutes < 10 ? 1 : 2);
    } else {
        str = @"1hour";
        initials = 1;
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDic];
    int len = [str length];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[RBZDateReminder instance].theme.mainColor range:NSMakeRange(0, initials)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(initials, len - initials)];
    return attrStr;
}

- (IBAction)onButtonTapped:(UIButton *)sender
{
    if (sender.tag < 0) {
        [self.delegate quickReminderPickerViewDidSelectNoReminder:self];
    } else {
        [self.delegate quickReminderPickerView:self didSelectReminder:sender.tag];
    }
}

@end

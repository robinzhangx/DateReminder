//
//  RBZQuickReminderPickerView.m
//  DateReminder
//
//  Created by robin on 2/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZQuickReminderPickerView.h"

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
    self.button5m.tag = 5;
    [self.button5m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.button10m.tag = 10;
    [self.button10m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.button15m.tag = 15;
    [self.button15m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.button30m.tag = 30;
    [self.button30m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.button60m.tag = 60;
    [self.button60m addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.noReminderButton.tag = -1;
    [self.noReminderButton addTarget:self action:@selector(onButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
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

//
//  RBZQuickReminderPickerView.h
//  DateReminder
//
//  Created by robin on 2/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RBZQuickReminderPickerView;

@protocol RBZQuickReminderPickerViewDelegate
- (void)quickReminderPickerView:(RBZQuickReminderPickerView *)view didSelectReminder:(NSInteger)minutes;
- (void)quickReminderPickerViewDidSelectNoReminder:(RBZQuickReminderPickerView *)view;
@end

@interface RBZQuickReminderPickerView : UIView

@property (nonatomic, assign) id<RBZQuickReminderPickerViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *button1m;
@property (weak, nonatomic) IBOutlet UIButton *button5m;
@property (weak, nonatomic) IBOutlet UIButton *button10m;
@property (weak, nonatomic) IBOutlet UIButton *button15m;
@property (weak, nonatomic) IBOutlet UIButton *button30m;
@property (weak, nonatomic) IBOutlet UIButton *button60m;
@property (weak, nonatomic) IBOutlet UIButton *noReminderButton;

@end

//
//  RBZQuickCalendarPickerView.h
//  DateReminder
//
//  Created by robin on 2/17/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RBZQuickCalendarPickerView;

@protocol RBZQuickCalendarPickerViewDelegate
- (void)quickCalendarPickerView:(RBZQuickCalendarPickerView *)view didSelectDate:(NSDate *)date;
- (void)quickCalendarPickerViewDidSelectDaily:(RBZQuickCalendarPickerView *)view;
- (void)quickCalendarPickerViewDidSelectPickOther:(RBZQuickCalendarPickerView *)view;
@end

@interface RBZQuickCalendarPickerView : UIView

@property (nonatomic, assign) id<RBZQuickCalendarPickerViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *button00;
@property (weak, nonatomic) IBOutlet UIButton *button01;
@property (weak, nonatomic) IBOutlet UIButton *button02;
@property (weak, nonatomic) IBOutlet UIButton *button03;
@property (weak, nonatomic) IBOutlet UIButton *button04;
@property (weak, nonatomic) IBOutlet UIButton *button05;
@property (weak, nonatomic) IBOutlet UIButton *button06;
@property (weak, nonatomic) IBOutlet UIButton *button10;
@property (weak, nonatomic) IBOutlet UIButton *button11;
@property (weak, nonatomic) IBOutlet UIButton *button12;
@property (weak, nonatomic) IBOutlet UIButton *button13;
@property (weak, nonatomic) IBOutlet UIButton *button14;
@property (weak, nonatomic) IBOutlet UIButton *button15;
@property (weak, nonatomic) IBOutlet UIButton *button16;
@property (weak, nonatomic) IBOutlet UIButton *button20;
@property (weak, nonatomic) IBOutlet UIButton *button21;
@property (weak, nonatomic) IBOutlet UIButton *button22;
@property (weak, nonatomic) IBOutlet UIButton *button23;
@property (weak, nonatomic) IBOutlet UIButton *button24;
@property (weak, nonatomic) IBOutlet UIButton *button25;
@property (weak, nonatomic) IBOutlet UIButton *button26;

@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UIButton *pickOtherButton;
@property (weak, nonatomic) IBOutlet UIButton *dailyButton;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UILabel *sundayLabel;
@property (weak, nonatomic) IBOutlet UILabel *saturdayLabel;

@end


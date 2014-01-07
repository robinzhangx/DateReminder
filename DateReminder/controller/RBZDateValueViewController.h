//
//  RBZDateValueViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-22.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventDate+Functions.h"

@interface RBZDateValueViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property NSNumber *type;
@property NSNumber *day;
@property NSNumber *weekday;
@property NSNumber *month;
@property NSNumber *year;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@end

//
//  RBZDateViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-22.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZDateViewController : UIViewController

@property NSNumber *day;
@property NSNumber *month;
@property NSNumber *year;

@property (weak, nonatomic) IBOutlet UIView *pickerContainer;
@property (weak, nonatomic) IBOutlet UIButton *setButton;

@end

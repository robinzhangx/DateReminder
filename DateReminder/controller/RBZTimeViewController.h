//
//  RBZTimeViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-20.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZTimeViewController : UIViewController

@property NSNumber *hour;
@property NSNumber *minute;

@property (weak, nonatomic) IBOutlet UIView *pickerContainer;
@property (weak, nonatomic) IBOutlet UIButton *setButton;

@end

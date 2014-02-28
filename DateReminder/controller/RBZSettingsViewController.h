//
//  RBZSettingsViewController.h
//  DateReminder
//
//  Created by robin on 2/24/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIControl *rateButton;
@property (weak, nonatomic) IBOutlet UIControl *mailButton;
@property (weak, nonatomic) IBOutlet UIControl *coffeeButton;
@property (weak, nonatomic) IBOutlet UILabel *coffeePriceLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *coffeeLabel;

@end

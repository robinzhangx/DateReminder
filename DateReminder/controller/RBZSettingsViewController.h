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
@property (weak, nonatomic) IBOutlet UILabel *coffeeLabel;

@property (weak, nonatomic) IBOutlet UIControl *color0Button;
@property (weak, nonatomic) IBOutlet UIView *color0Image;
@property (weak, nonatomic) IBOutlet UIControl *color1Button;
@property (weak, nonatomic) IBOutlet UIView *color1Image;
@property (weak, nonatomic) IBOutlet UIControl *color2Button;
@property (weak, nonatomic) IBOutlet UIView *color2Image;
@property (weak, nonatomic) IBOutlet UIControl *color3Button;
@property (weak, nonatomic) IBOutlet UIView *color3Image;
@property (weak, nonatomic) IBOutlet UIImageView *colorCheckmark;

@end

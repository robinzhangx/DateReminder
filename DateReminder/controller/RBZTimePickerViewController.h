//
//  RBZTimePickerViewController.h
//  DateReminder
//
//  Created by robin on 2/15/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZTimePickerViewController : UIViewController

@property NSNumber *hour;
@property NSNumber *minute;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *setButton;

@property (weak, nonatomic) IBOutlet UIView *hourHighlight;
@property (weak, nonatomic) IBOutlet UIView *minuteHighlight;
@property (weak, nonatomic) IBOutlet UIView *m05Highlight;
@property (weak, nonatomic) IBOutlet UIView *ampmHighlight;

@property (weak, nonatomic) IBOutlet UIButton *h1Button;
@property (weak, nonatomic) IBOutlet UIButton *h2Button;
@property (weak, nonatomic) IBOutlet UIButton *h3Button;
@property (weak, nonatomic) IBOutlet UIButton *h4Button;
@property (weak, nonatomic) IBOutlet UIButton *h5Button;
@property (weak, nonatomic) IBOutlet UIButton *h6Button;
@property (weak, nonatomic) IBOutlet UIButton *h7Button;
@property (weak, nonatomic) IBOutlet UIButton *h8Button;
@property (weak, nonatomic) IBOutlet UIButton *h9Button;
@property (weak, nonatomic) IBOutlet UIButton *h10Button;
@property (weak, nonatomic) IBOutlet UIButton *h11Button;
@property (weak, nonatomic) IBOutlet UIButton *h12Button;
@property (weak, nonatomic) IBOutlet UIButton *m00Button;
@property (weak, nonatomic) IBOutlet UIButton *m10Button;
@property (weak, nonatomic) IBOutlet UIButton *m20Button;
@property (weak, nonatomic) IBOutlet UIButton *m30Button;
@property (weak, nonatomic) IBOutlet UIButton *m40Button;
@property (weak, nonatomic) IBOutlet UIButton *m50Button;
@property (weak, nonatomic) IBOutlet UIButton *m05Button;

@property (weak, nonatomic) IBOutlet UIButton *amButton;
@property (weak, nonatomic) IBOutlet UIButton *pmButton;
@property (weak, nonatomic) IBOutlet UIButton *plus5mButton;
@property (weak, nonatomic) IBOutlet UIButton *plus10mButton;
@property (weak, nonatomic) IBOutlet UIButton *plus30mButton;
@property (weak, nonatomic) IBOutlet UIButton *plus1hButton;


@end

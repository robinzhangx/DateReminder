//
//  RBZMainViewController.h
//  DateReminder
//
//  Created by robin on 2/12/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZEventViewController.h"

@interface RBZMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RBZEventViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *hudContainerView;
@property (weak, nonatomic) IBOutlet UIButton *hudButton;
@property (weak, nonatomic) IBOutlet UILabel *hudTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hudTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *hudTimeView;
@property (weak, nonatomic) IBOutlet UIView *hudLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *hudHintLabel;

@property (weak, nonatomic) IBOutlet UIView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tomorrowContainerView;
@property (weak, nonatomic) IBOutlet UIView *todayContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tomorrowTableView;
@property (weak, nonatomic) IBOutlet UITableView *todayTableView;
@property (weak, nonatomic) IBOutlet UIButton *tomorrowButton;
@property (weak, nonatomic) IBOutlet UIButton *todayButton;
@property (weak, nonatomic) IBOutlet UIView *popupContainer;
@property (weak, nonatomic) IBOutlet UIView *popupView;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *archiveButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hudTimeViewWidthConstraint;

- (IBAction)unwindFromArchive:(UIStoryboardSegue *)segue;

@end

//
//  RBZEventListViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-12.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZEventViewController.h"
#import "RBZSettingsViewController.h"

@interface RBZEventListViewController
    : UIViewController <UITableViewDelegate, UITableViewDataSource, RBZEventViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *toastLabel;

- (void)navigateToAllEvent;

@end

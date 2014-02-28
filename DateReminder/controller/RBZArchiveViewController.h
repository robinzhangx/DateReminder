//
//  RBZArchiveViewController.h
//  DateReminder
//
//  Created by robin on 2/24/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZEventViewController.h"

@interface RBZArchiveViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, RBZEventViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIView *headerContainerView;
@property (weak, nonatomic) IBOutlet UIView *listContainerView;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property BOOL hasDataChange;

@end

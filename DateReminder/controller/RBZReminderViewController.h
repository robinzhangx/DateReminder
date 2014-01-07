//
//  RBZReminderViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-23.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZReminderViewController : UITableViewController

@property NSNumber *hasReminder;
@property NSNumber *minutesBefore;

@property (weak, nonatomic) IBOutlet UITableViewCell *noCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *m1Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *m5Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *m10Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *m15Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *m30Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *h1Cell;

@end

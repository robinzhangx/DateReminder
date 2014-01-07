//
//  RBZSettingsViewController.h
//  Date Reminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZSettingsTableViewController.h"

@interface RBZSettingsViewController : UIViewController <RBZSettingsTableDelegate>

- (void)updateAllEventsLabel;

@end

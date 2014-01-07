//
//  RBZTypeViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-22.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZEventDateValueDelegate.h"

@interface RBZTypeViewController : UITableViewController

@property NSNumber *type;
@property NSNumber *day;
@property NSNumber *month;
@property NSNumber *weekday;
@property NSNumber *year;

@property (nonatomic, assign) id<RBZEventDateValueDelegate> delegate;

@end

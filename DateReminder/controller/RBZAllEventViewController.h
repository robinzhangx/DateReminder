//
//  RBZAllEventViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-24.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZEventViewController.h"

@interface RBZAllEventViewController : UITableViewController <RBZEventViewDelegate>

@property BOOL changed;

@end

//
//  RBZSettingsTableViewController.h
//  Date Reminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RBZSettingsTableDelegate <NSObject>

- (void)onListAllTapped;

@end

@interface RBZSettingsTableViewController : UITableViewController

@property (weak, nonatomic) id<RBZSettingsTableDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *listAllLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyCoffeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyCoffeePriceLabel;

- (void)updateAllEventsLabel;

@end

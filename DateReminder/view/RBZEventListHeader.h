//
//  RBZEventListHeader.h
//  Date Reminder
//
//  Created by robin on 13-12-5.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZEventListHeader : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

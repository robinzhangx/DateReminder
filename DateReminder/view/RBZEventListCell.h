//
//  RBZEventListCell.h
//  Date Reminder
//
//  Created by robin on 13-12-5.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZEventListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *leftIndicator;
@property (weak, nonatomic) IBOutlet UIView *rightIndicator;

@end

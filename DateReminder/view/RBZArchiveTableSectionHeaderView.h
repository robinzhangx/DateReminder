//
//  RBZArchiveTableSectionHeaderView.h
//  DateReminder
//
//  Created by robin on 2/25/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBZArchiveTableSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIControl *contentControlView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

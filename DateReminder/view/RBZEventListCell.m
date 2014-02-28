//
//  RBZEventListCell.m
//  Date Reminder
//
//  Created by robin on 13-12-5.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZEventListCell.h"

@implementation RBZEventListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.leftIndicator.layer.opacity = 0.8;
    self.leftIndicator.hidden = YES;
    self.rightIndicator.layer.opacity = 0.8;
    self.rightIndicator.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end

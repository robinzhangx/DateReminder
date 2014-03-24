//
//  RBZArchiveListCell.m
//  DateReminder
//
//  Created by robin on 2/25/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZArchiveListCell.h"
#import "RBZDateReminder.h"

@implementation RBZArchiveListCell

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
    self.indicatorView.backgroundColor = [RBZDateReminder instance].theme.mainColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

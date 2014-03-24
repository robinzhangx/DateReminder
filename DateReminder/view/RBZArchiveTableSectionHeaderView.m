//
//  RBZArchiveTableSectionHeaderView.m
//  DateReminder
//
//  Created by robin on 2/25/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZArchiveTableSectionHeaderView.h"
#import "RBZDateReminder.h"

@implementation RBZArchiveTableSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.countLabel.layer.cornerRadius = 3.0;
    self.indicatorView.backgroundColor = [RBZDateReminder instance].theme.mainColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

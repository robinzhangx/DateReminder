//
//  RBZEventBadgeCell.m
//  DateReminder
//
//  Created by robin on 2/22/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZEventBadgeCell.h"

@implementation RBZEventBadgeCell

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
    self.containerView.layer.cornerRadius = 3.0;
}

@end

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
- (void)showIndicator
{
    self.indicatorView.layer.cornerRadius = 5.0;
    self.indicatorConstraint.constant = 10.0;
    self.titleConstraint.constant = 30.0;
    self.indicatorView.alpha = 1.0f;
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.indicatorView.alpha = 0.1f;
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
}

- (void)hideIndicator
{
    self.indicatorConstraint.constant = -10.0;
    self.titleConstraint.constant = 15.0;
}
 */

@end

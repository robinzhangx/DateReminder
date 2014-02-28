//
//  RBZEventBadgeFlowLayout.m
//  DateReminder
//
//  Created by robin on 2/22/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZEventBadgeFlowLayout.h"

@implementation RBZEventBadgeFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    static int maxSpacing = 8.0;
    NSArray *layouts = [super layoutAttributesForElementsInRect:rect];
    
    if ([layouts count] > 0) {
        /*
        for (UICollectionViewLayoutAttributes *attrs in layouts) {
            NSLog(@"%@", NSStringFromCGRect(attrs.frame));
        }
        */
        UICollectionViewLayoutAttributes *first = layouts[0];
        CGRect frame = first.frame;
        frame.origin.x = 0.0;
        first.frame = frame;
    }
    for (int i = 1; i < [layouts count]; i++) {
        UICollectionViewLayoutAttributes *currAttrs = layouts[i];
        UICollectionViewLayoutAttributes *prevAttrs = layouts[i - 1];
        CGFloat origin = CGRectGetMaxX(prevAttrs.frame);
        if (currAttrs.center.y > prevAttrs.center.y) {
            CGRect frame = currAttrs.frame;
            frame.origin.x = 0.0;
            currAttrs.frame = frame;
        } else {
            if (origin + maxSpacing + currAttrs.frame.size.width < self.collectionViewContentSize.width) {
                CGRect frame = currAttrs.frame;
                frame.origin.x = origin + maxSpacing;
                currAttrs.frame = frame;
            }
        }
    }
    
    return layouts;
}

@end

//
//  RBZArrowView.m
//  DateReminder
//
//  Created by robin on 2/27/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZArrowView.h"

@implementation RBZArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.color setFill];
    switch (self.edge) {
        case UIRectEdgeLeft:
            CGContextMoveToPoint(ctx, self.frame.size.width, 0.0);
            CGContextAddLineToPoint(ctx, 0.0, self.frame.size.height / 2.0);
            CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
            CGContextClosePath(ctx);
            break;
        case UIRectEdgeTop:
            CGContextMoveToPoint(ctx, 0.0, self.frame.size.height);
            CGContextAddLineToPoint(ctx, self.frame.size.width / 2.0, 0.0);
            CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
            CGContextClosePath(ctx);
            break;
        case UIRectEdgeRight:
            CGContextMoveToPoint(ctx, 0.0, 0.0);
            CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height / 2.0);
            CGContextAddLineToPoint(ctx, 0.0, self.frame.size.height);
            CGContextClosePath(ctx);
            break;
        case UIRectEdgeBottom:
            CGContextMoveToPoint(ctx, 0.0, 0.0);
            CGContextAddLineToPoint(ctx, self.frame.size.width / 2.0, self.frame.size.height);
            CGContextAddLineToPoint(ctx, self.frame.size.width, 0.0);
            CGContextClosePath(ctx);
            break;
    }
    CGContextFillPath(ctx);
}

@end
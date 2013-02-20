//
//  SFHorizontalGridlineCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFHorizontalGridlineCollectionReusableView.h"

@implementation SFHorizontalGridlineCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.shadowColor = [[UIColor colorWithWhite:0.15 alpha:1.0] CGColor];
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 0.0;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:(CGRect){CGPointMake(0.0, 4.0), self.frame.size }] CGPath];
}

@end

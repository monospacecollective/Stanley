//
//  SFCollectionCellBackgroundView.m
//  Stanley
//
//  Created by Eric Horacek on 3/14/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFCollectionCellBackgroundView.h"
#import "SFStyleManager.h"

@interface SFCollectionCellBackgroundView ()

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation SFCollectionCellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 0.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeZero;
        
        self.shadowView = [UIView new];
        self.shadowView.backgroundColor = [[SFStyleManager sharedManager] secondaryViewBackgroundColor];
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.shadowView.layer.shadowRadius = 3.0;
        self.shadowView.layer.shadowOpacity = 0.5;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.shadowView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.1] CGColor];
        self.shadowView.layer.borderWidth = 1.0;
        [self addSubview:self.shadowView];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect shadowFrame = (CGRect){CGPointZero, self.frame.size};
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(shadowFrame, -2.0, -2.0)] CGPath];
    self.shadowView.frame = shadowFrame;
    self.shadowView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(shadowFrame, -2.0, -2.0)] CGPath];
}

@end

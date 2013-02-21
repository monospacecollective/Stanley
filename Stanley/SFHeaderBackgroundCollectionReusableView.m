//
//  SFHeaderBackgroundCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFHeaderBackgroundCollectionReusableView.h"
#import "SFStyleManager.h"

@interface SFHeaderBackgroundCollectionReusableView ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation SFHeaderBackgroundCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundView = [UIView new];
        self.backgroundView.frame = (CGRect){CGPointZero, frame.size};
        self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.backgroundView.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];
        self.backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.backgroundView.layer.shadowRadius = 3.0;
        self.backgroundView.layer.shadowOpacity = 0.5;
        self.backgroundView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        [self addSubview:self.backgroundView];
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 0.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeZero;
        
        self.layer.borderColor = [[UIColor colorWithWhite:0.15 alpha:1.0] CGColor];
        self.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.backgroundView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, bounds.size}] CGPath];
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset((CGRect){CGPointZero, bounds.size}, -2.0, -2.0)] CGPath];
}

@end

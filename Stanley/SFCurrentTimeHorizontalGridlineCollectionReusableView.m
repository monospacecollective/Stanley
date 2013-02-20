//
//  SFCurrentTimeHorizontalGridlineCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFCurrentTimeHorizontalGridlineCollectionReusableView.h"

@interface SFCurrentTimeHorizontalGridlineCollectionReusableView ()

@property (nonatomic, strong) UIImageView *backgroundImage;

@end

@implementation SFCurrentTimeHorizontalGridlineCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"SFCurrentTimeHorizontalGridlineBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)];
        self.backgroundImage = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:self.backgroundImage];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundImage.frame = (CGRect){CGPointZero, {(self.frame.size.width + 2.0), self.frame.size.height}};
}

@end

//
//  SFTimeRowHeaderCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFTimeRowHeaderCollectionReusableView.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@implementation SFTimeRowHeaderCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.time = [UILabel new];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.textColor = [UIColor colorWithHexString:@"aaaaaa"];
        self.time.font = [[SFStyleManager sharedManager] detailFontOfSize:15.0];
        self.time.textAlignment = UITextAlignmentRight;
        self.time.shadowColor = [UIColor blackColor];
        self.time.shadowOffset = CGSizeMake(0.0, -1.0);
        [self addSubview:self.time];
        
#if defined(LAYOUT_DEBUG)
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1.0;
#endif
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.time sizeToFit];
    CGRect timeFrame = self.time.frame;
    timeFrame.size.width = (CGRectGetWidth(self.frame) - (self.class.padding.width * 2.0));
    timeFrame.origin.x = self.class.padding.width;
    timeFrame.origin.y = nearbyintf((CGRectGetHeight(self.frame) / 2.0) - (CGRectGetHeight(timeFrame) / 2.0));
    self.time.frame = timeFrame;
}

+ (CGSize)padding
{
    return CGSizeMake(8.0, 0.0);
}

@end

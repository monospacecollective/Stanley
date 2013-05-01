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

@interface SFTimeRowHeaderCollectionReusableView ()

+ (UIEdgeInsets)padding;

@end

@implementation SFTimeRowHeaderCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.time = [UILabel new];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.textColor = [UIColor colorWithHexString:@"aaaaaa"];
        self.time.font = [[SFStyleManager sharedManager] detailFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 15.0 : 15.0) condensed:(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) oblique:NO];
        self.time.textAlignment = NSTextAlignmentRight;
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
    timeFrame.size.width = (CGRectGetWidth(self.frame) - (self.class.padding.left + self.class.padding.right));
    timeFrame.origin.x = self.class.padding.left;
    timeFrame.origin.y = nearbyintf((CGRectGetHeight(self.frame) / 2.0) - (CGRectGetHeight(timeFrame) / 2.0) + 2.0);
    self.time.frame = timeFrame;
}

+ (UIEdgeInsets)padding
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(0.0, 0.0, 0.0, 15.0) : UIEdgeInsetsMake(0.0, 0.0, 0.0, 6.0));
}

@end

//
//  SFPopoverToolbar.m
//  Stanley
//
//  Created by Eric Horacek on 3/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFPopoverToolbar.h"

@interface SFPopoverToolbar ()

+ (CGFloat)barHeight;

@end

@implementation SFPopoverToolbar

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.translucent = YES;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([super sizeThatFits:size].width, self.class.barHeight);
}

#pragma mark - SFPopoverToolbar

+ (CGFloat)barHeight
{
    return 50.0;
}

@end

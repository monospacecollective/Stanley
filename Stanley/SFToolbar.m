//
//  SFToolbar.m
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFToolbar.h"

@interface SFToolbar ()

+ (CGFloat)barHeight;

@end

@implementation SFToolbar

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"SFHeaderBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0)];
        [self setBackgroundImage:backgroundImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([super sizeThatFits:size].width, self.class.barHeight);
}

#pragma mark - SFToolbar

+ (CGFloat)barHeight
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 56.0 : 46.0);
}

@end

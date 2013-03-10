//
//  SFPopoverNavigationBar.m
//  Stanley
//
//  Created by Eric Horacek on 3/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFPopoverNavigationBar.h"
#import "SFStyleManager.h"

@interface SFPopoverNavigationBar ()

+ (CGFloat)barHeight;
+ (UIFont *)titleTextFont;

@end

@implementation SFPopoverNavigationBar

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.titleTextAttributes = @{
            UITextAttributeFont : self.class.titleTextFont,
            UITextAttributeTextColor : [UIColor whiteColor],
            UITextAttributeTextShadowColor : [UIColor blackColor],
            UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)]
        };
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([super sizeThatFits:size].width, self.class.barHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    for (UIView *subview in self.subviews) {
        // Hacky...
        if ([subview isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            CGRect navigationItemFrame = subview.frame;
            navigationItemFrame.origin.y = 9.0;
            navigationItemFrame.size.height = self.class.titleTextFont.lineHeight;
            subview.frame = navigationItemFrame;
        }
        // If it's the right navigation button
        else if ([subview isKindOfClass:UIButton.class] && (CGRectGetMinX(subview.frame) < CGRectGetMidX(self.frame))) {
            CGRect buttonFrame = subview.frame;
            buttonFrame.origin.y = 2.0;
            subview.frame = buttonFrame;
        }
    }
}

#pragma mark - SFPopoverNavigationBar

+ (CGFloat)barHeight
{
    return 50.0;
}

+ (UIFont *)titleTextFont
{
    return [[SFStyleManager sharedManager] navigationFontOfSize:30.0];
}

@end

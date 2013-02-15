//
//  SFNavigationBar.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFNavigationBar.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@interface SFNavigationBar ()

+ (CGFloat)barHeight;
+ (UIFont *)titleTextFont;

@end

@implementation SFNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"SFHeaderBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0)];
        [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        self.titleTextAttributes = @{
            UITextAttributeFont : self.class.titleTextFont,
            UITextAttributeTextColor : [UIColor whiteColor],
            UITextAttributeTextShadowColor : [UIColor blackColor],
            UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)]
        };
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (UIView *subview in self.subviews) {
            // Hacky...
            if ([subview isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
                CGRect navigationItemFrame = subview.frame;
                navigationItemFrame.origin.y = 13.0;
                navigationItemFrame.size.height = self.class.titleTextFont.lineHeight;
                subview.frame = navigationItemFrame;
#if defined(LAYOUT_DEBUG)
                subview.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
#endif
            }
            else if ([subview isKindOfClass:UIButton.class]) {
                CGRect buttonFrame = subview.frame;
                buttonFrame.origin.y = 6.0;
                subview.frame = buttonFrame;
            }
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize = CGSizeMake([super sizeThatFits:size].width, self.class.barHeight);
    return newSize;
}

+ (CGFloat)barHeight
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 56.0 : 46.0);
}

+ (UIFont *)titleTextFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 32.0 : 25.0);
    return [[SFStyleManager sharedManager] navigationFontOfSize:fontSize];
}

@end

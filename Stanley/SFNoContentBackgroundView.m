//
//  SFNoContentBackgroundView.m
//  Stanley
//
//  Created by Eric Horacek on 3/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFNoContentBackgroundView.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@implementation SFNoContentBackgroundView

#pragma mark - UIVIew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.title = [FXLabel new];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.title.font = [[SFStyleManager sharedManager] titleFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.0 : 28.0)];
        self.title.numberOfLines = 0;
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.gradientStartColor = [UIColor colorWithHexString:@"828282"];
        self.title.gradientEndColor = [UIColor colorWithHexString:@"686868"];
        self.title.innerShadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        self.title.innerShadowOffset = CGSizeMake(0.0, 1.0);
        self.title.shadowColor = [UIColor blackColor];
        self.title.shadowOffset = CGSizeMake(0.0, 3.0);
        self.title.layer.masksToBounds = NO;
        [self addSubview:self.title];
        
        self.icon = [FXLabel new];
        self.icon.backgroundColor = [UIColor clearColor];
        self.icon.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.icon.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 170.0 : 120.0)];
        self.icon.textAlignment = NSTextAlignmentCenter;
        self.icon.gradientStartColor = [UIColor colorWithHexString:@"828282"];
        self.icon.gradientEndColor = [UIColor colorWithHexString:@"686868"];
        self.icon.innerShadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        self.icon.innerShadowOffset = CGSizeMake(0.0, 1.0);
        self.icon.shadowColor = [UIColor blackColor];
        self.icon.shadowOffset = CGSizeMake(0.0, 3.0);
        self.icon.layer.masksToBounds = NO;
        [self addSubview:self.icon];
        
        self.subtitle = [FXLabel new];
        self.subtitle.backgroundColor = [UIColor clearColor];
        self.subtitle.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.subtitle.font = [[SFStyleManager sharedManager] detailFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 22.0 : 20.0)];
        self.subtitle.numberOfLines = 0;
        self.subtitle.textAlignment = NSTextAlignmentCenter;
        self.subtitle.gradientStartColor = [UIColor colorWithHexString:@"828282"];
        self.subtitle.gradientEndColor = [UIColor colorWithHexString:@"686868"];
        self.subtitle.innerShadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        self.subtitle.innerShadowOffset = CGSizeMake(0.0, 1.0);
        self.subtitle.shadowColor = [UIColor blackColor];
        self.subtitle.shadowOffset = CGSizeMake(0.0, 2.0);
        self.subtitle.layer.masksToBounds = NO;
        [self addSubview:self.subtitle];
        
#if defined(LAYOUT_DEBUG)
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.title.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        self.subtitle.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        self.icon.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL iphone568 = (UIScreen.mainScreen.bounds.size.height == 568.0);
    CGSize padding = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? CGSizeMake(200.0, 200.0) : CGSizeMake(340.0, 120.0)) : (iphone568 ? CGSizeMake(30.0, 60.0) : CGSizeMake(30.0, 30.0)));
    
    CGFloat maxWidth = CGRectGetWidth(self.frame) - (padding.width * 2.0);
    
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:self.title.lineBreakMode];
    CGRect titleFrame = self.title.frame;
    titleFrame.size = titleSize;
    titleFrame.origin.x = nearbyintf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(titleFrame) / 2.0));
    titleFrame.origin.y = padding.height;
    self.title.frame = titleFrame;

    CGSize subtitleSize = [self.subtitle.text sizeWithFont:self.subtitle.font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:self.subtitle.lineBreakMode];
    CGRect subtitleFrame = self.subtitle.frame;
    subtitleFrame.size = subtitleSize;
    subtitleFrame.origin.x = nearbyintf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(subtitleFrame) / 2.0));
    subtitleFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(subtitleFrame) - padding.height);
    self.subtitle.frame = subtitleFrame;
    
    CGSize iconSize = [self.icon.text sizeWithFont:self.icon.font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:self.icon.lineBreakMode];
    CGRect iconFrame = self.icon.frame;
    iconFrame.size = iconSize;
    iconFrame.origin.x = nearbyintf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(iconFrame) / 2.0));
    
    CGFloat centerDistance = nearbyintf(CGRectGetMinY(subtitleFrame) - CGRectGetMaxY(titleFrame));
    iconFrame.origin.y = nearbyintf((CGRectGetMaxY(titleFrame) + (centerDistance / 2.0)) - (CGRectGetHeight(iconFrame)) + nearbyintf(self.icon.font.lineHeight / 1.8));
    self.icon.frame = iconFrame;
}

@end

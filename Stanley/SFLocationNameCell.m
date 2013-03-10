//
//  SFLocationNameCell.m
//  Stanley
//
//  Created by Eric Horacek on 3/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFLocationNameCell.h"
#import "SFStyleManager.h"

@interface SFLocationNameCell ()

@property (nonatomic, strong) CAGradientLayer *backgroundGradient;

@end

@implementation SFLocationNameCell

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize padding = self.class.padding;
    CGSize maxContentSize = CGRectInset(self.contentView.frame, padding.width, padding.height).size;
    
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:maxContentSize lineBreakMode:self.title.lineBreakMode];
    CGRect titleFrame = self.title.frame;
    titleFrame.size = titleSize;
    titleFrame.origin.x = padding.width;
    // Add a third of the line height so that the baseline is the true bottom of the frame
    titleFrame.origin.y = CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(titleFrame) - padding.height + ceilf(self.title.font.lineHeight * 0.3);
    self.title.frame = titleFrame;
    
    CGFloat minTitleLocation = (CGRectGetMinY(titleFrame) / CGRectGetHeight(self.contentView.frame));
    self.backgroundGradient.locations = @[@(minTitleLocation - 0.2), @(minTitleLocation)];
    self.backgroundGradient.frame = (CGRect){CGPointZero, self.map.frame.size};
}

#pragma mark - UITableCell

- (void)initialize
{
    [super initialize];
    
    self.title.numberOfLines = 0;
    self.title.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.title.layer.shadowRadius = 2.0;
    self.title.layer.shadowOpacity = 1.0;
    self.title.layer.shadowOffset = CGSizeZero;
    self.title.layer.masksToBounds = NO;
    
    [self setTitleTextAttributes:@{
            UITextAttributeFont : self.class.titleFont,
       UITextAttributeTextColor : [UIColor whiteColor],
 UITextAttributeTextShadowColor : [UIColor clearColor],
UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeZero]
     } forState:UIControlStateNormal];
    
    self.backgroundGradient = [CAGradientLayer layer];
    UIColor *overlayColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundGradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[overlayColor CGColor]];
    self.backgroundGradient.locations = @[@(0.7), @(0.9)];
    [self.map.layer addSublayer:self.backgroundGradient];
}

#pragma mark - SFLocationNameCell

+ (CGSize)padding
{
    return CGSizeMake(15.0, 15.0);
}

+ (UIFont *)titleFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 25.0 : 23.0);
    return [[SFStyleManager sharedManager] titleFontOfSize:fontSize];
}

@end

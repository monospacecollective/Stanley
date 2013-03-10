//
//  SFHeroCell.m
//  Stanley
//
//  Created by Eric Horacek on 3/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFHeroCell.h"
#import "SFStyleManager.h"

@interface SFHeroCell ()

@property (nonatomic, strong) CAGradientLayer *backgroundGradient;

@end

@implementation SFHeroCell

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
    
    self.backgroundImage.frame = (CGRect){CGPointZero, self.groupedCellBackgroundView.frame.size};
    
    CGFloat minTitleLocation = (CGRectGetMinY(titleFrame) / CGRectGetHeight(self.contentView.frame));
    self.backgroundGradient.locations = @[@(minTitleLocation - 0.2), @(minTitleLocation)];
    self.backgroundGradient.frame = (CGRect){CGPointZero, self.groupedCellBackgroundView.frame.size};
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
        UITextAttributeFont : [[SFStyleManager sharedManager] titleFontOfSize:23.0],
        UITextAttributeTextColor : [UIColor whiteColor],
        UITextAttributeTextShadowColor : [UIColor clearColor],
        UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeZero]
    } forState:UIControlStateNormal];
    
    self.backgroundImage = [UIImageView new];
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.backgroundColor = [[SFStyleManager sharedManager] secondaryViewBackgroundColor];
    self.backgroundImage.layer.cornerRadius = 2.0;
    self.backgroundImage.layer.masksToBounds = YES;
    self.backgroundImage.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
    self.backgroundImage.layer.borderWidth = 1.0;
    [self.contentView insertSubview:self.backgroundImage belowSubview:self.title];
    
    self.backgroundGradient = [CAGradientLayer layer];
    UIColor *overlayColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.backgroundGradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[overlayColor CGColor]];
    self.backgroundGradient.locations = @[@(0.7), @(0.9)];
    [self.backgroundImage.layer addSublayer:self.backgroundGradient];
    
    self.padding = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
}

+ (CGFloat)height
{
    return 200.0;
}

#pragma mark - SFHeroCell

+ (CGSize)padding
{
    return CGSizeMake(15.0, 15.0);
}

@end

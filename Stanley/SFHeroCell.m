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

#pragma mark - UIView

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    [self.title pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0];
    NSDictionary *views = @{ @"title" : self.title };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[title]|" options:0 metrics:nil views:views]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.title.preferredMaxLayoutWidth = CGRectGetWidth(self.contentView.frame);
    
    CGFloat minTitleLocation = (CGRectGetMinY(self.title.frame) / CGRectGetHeight(self.contentView.frame));
    self.backgroundGradient.locations = @[@(minTitleLocation - 0.2), @(minTitleLocation)];
    self.backgroundGradient.frame = (CGRect){CGPointZero, self.groupedCellBackgroundView.frame.size};
}

#pragma mark - UITableCell

- (void)initialize
{
    [super initialize];
    
    self.selectionStyle = MSTableCellSelectionStyleNone;
    
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
    
    self.padding = UIEdgeInsetsMake(12.0, 24.0, 4.0, 24.0);
    
    self.backgroundImage = [UIImageView new];
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImage.backgroundColor = [[SFStyleManager sharedManager] secondaryViewBackgroundColor];
    self.backgroundImage.layer.cornerRadius = 2.0;
    self.backgroundImage.layer.masksToBounds = YES;
    self.backgroundImage.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
    self.backgroundImage.layer.borderWidth = 1.0;
    self.backgroundView = self.backgroundImage;
    
    self.backgroundGradient = [CAGradientLayer layer];
    UIColor *overlayColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.backgroundGradient.colors = @[(id)[[UIColor clearColor] CGColor], (id)[overlayColor CGColor]];
    self.backgroundGradient.locations = @[@(0.7), @(0.9)];
    [self.backgroundImage.layer addSublayer:self.backgroundGradient];
}

+ (CGFloat)height
{
    return 200.0;
}

@end

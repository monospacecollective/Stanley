//
//  SFPopoverBackgroundView.m
//  Stanley
//
//  Created by Eric Horacek on 4/10/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFPopoverBackgroundView.h"

@interface SFPopoverBackgroundView ()

@property (nonatomic, strong) UIImage *topArrowImage;
@property (nonatomic, strong) UIImage *leftArrowImage;
@property (nonatomic, strong) UIImage *rightArrowImage;
@property (nonatomic, strong) UIImage *bottomArrowImage;

@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImageView *centerImageView;

- (void)initialize;

@end

@implementation SFPopoverBackgroundView

@synthesize arrowOffset = _arrowOffset;
@synthesize arrowDirection = _arrowDirection;

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect popoverRect = (CGRect){CGPointZero, self.bounds.size};
    
    UIImage *arrowImage;
    CGPoint arrowOrigin = CGPointZero;
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            arrowImage = self.topArrowImage;
            popoverRect.origin.y = arrowImage.size.height;
            popoverRect.size.height = nearbyintf(popoverRect.size.height - arrowImage.size.height);
            arrowOrigin.y -= self.arrowAdjustment;
            break;
        case UIPopoverArrowDirectionDown:
            arrowImage = self.bottomArrowImage;
            popoverRect.size.height = nearbyintf(popoverRect.size.height - arrowImage.size.height);
            arrowOrigin.y = nearbyintf(popoverRect.size.height + self.arrowAdjustment);
            break;
        case UIPopoverArrowDirectionLeft:
            arrowImage = self.leftArrowImage;
            popoverRect.origin.x = arrowImage.size.width;
            popoverRect.size.width = nearbyintf(popoverRect.size.width - arrowImage.size.width);
            arrowOrigin.x -= self.arrowAdjustment;
            break;
        case UIPopoverArrowDirectionRight:
            arrowImage = self.rightArrowImage;
            popoverRect.size.width = nearbyintf(popoverRect.size.width - arrowImage.size.width);
            arrowOrigin.x = nearbyintf(popoverRect.size.width + self.arrowAdjustment);;
            break;
        default:
            popoverRect.size.height = nearbyintf(self.bounds.size.height - arrowImage.size.height);
            break;
    }
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
        case UIPopoverArrowDirectionDown:
            arrowOrigin.x = nearbyintf(((popoverRect.size.width - arrowImage.size.width) / 2.0) + self.arrowOffset);
            if (arrowOrigin.x < self.cornerRadius) {
                arrowOrigin.x = self.cornerRadius;
            } else if ((arrowOrigin.x + arrowImage.size.width) > (popoverRect.size.width - self.cornerRadius)) {
                arrowOrigin.x = nearbyintf(popoverRect.size.width - self.cornerRadius - arrowImage.size.height);
            }
            break;
        case UIPopoverArrowDirectionRight:
        case UIPopoverArrowDirectionLeft:
            arrowOrigin.y = nearbyintf(((popoverRect.size.height - arrowImage.size.height) / 2.0) + self.arrowOffset);
            if (arrowOrigin.y < self.cornerRadius) {
                arrowOrigin.y = self.cornerRadius;
            } else if ((arrowOrigin.y + arrowImage.size.height) > (popoverRect.size.height - self.cornerRadius)) {
                arrowOrigin.y = nearbyintf(popoverRect.size.height - self.cornerRadius - arrowImage.size.height);
            }
            break;
        default:
            break;
    }
    
    self.centerImageView.frame = CGRectMake(popoverRect.origin.x, popoverRect.origin.y, popoverRect.size.width, popoverRect.size.height);
    
    self.arrowImageView.image = arrowImage;
    self.arrowImageView.frame = (CGRect){arrowOrigin, arrowImage.size};
}

#pragma mark - UIPopoverBackgroundView

+ (CGFloat)arrowBase
{
    return 36.0;
}

+ (CGFloat)arrowHeight
{
    return 19.0;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(10.0, 12.0, 12.0, 12.0);
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

#pragma mark - SFPopoverBackgroundView

- (void)initialize
{
    // Defaults
    _arrowAdjustment = -2.0;
    _cornerRadius = 12.0;
    
    self.topArrowImage = [UIImage imageNamed:@"SFPopoverBackgroundViewArrowTop"];
    self.leftArrowImage = [UIImage imageNamed:@"SFPopoverBackgroundViewArrowLeft"];
    self.bottomArrowImage = [UIImage imageNamed:@"SFPopoverBackgroundViewArrowBottom"];
    self.rightArrowImage = [UIImage imageNamed:@"SFPopoverBackgroundViewArrowRight"];
    
    self.centerImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SFPopoverBackgroundViewCenter"] resizableImageWithCapInsets:UIEdgeInsetsMake(self.cornerRadius, self.cornerRadius, self.cornerRadius, self.cornerRadius)]];
    [self addSubview:self.centerImageView];
    
    self.arrowImageView = [[UIImageView alloc] init];
    [self addSubview:self.arrowImageView];
}

@end

//
//  SFInstagramPhotoCell.m
//  Stanley
//
//  Created by Eric Horacek on 3/13/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFInstagramPhotoCell.h"
#import "SFStyleManager.h"

@interface SFInstagramPhotoCell ()

@property (nonatomic, strong) UIView *imageShadowView;

@end

@implementation SFInstagramPhotoCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        self.userLabel.backgroundColor = [UIColor clearColor];
        self.userLabel.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.userLabel.font = [[SFStyleManager sharedManager] titleFontOfSize:17.0];
        self.userLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.userLabel.layer.shadowRadius = 2.0;
        self.userLabel.layer.shadowOpacity = 1.0;
        self.userLabel.layer.shadowOffset = CGSizeZero;
        self.userLabel.layer.masksToBounds = NO;
        
        self.userImageView.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];
        self.userImageView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.3] CGColor];
        self.userImageView.layer.borderWidth = 1.0;
        self.userImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.userImageView.layer.shadowRadius = 0.0;
        self.userImageView.layer.shadowOpacity = 1.0;
        self.userImageView.layer.shadowOffset = CGSizeZero;
        
        self.imageView.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];
        self.imageView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.3] CGColor];
        self.imageView.layer.borderWidth = 1.0;
        
        self.imageShadowView = [UIView new];
        self.imageShadowView.backgroundColor = [UIColor blackColor];
        self.imageShadowView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView insertSubview:self.imageShadowView belowSubview:self.imageView];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.imageShadowView pinToEdgesOfView:self.imageView withInset:UIEdgeInsetsMake(-1.0, -1.0, 1.0, 1.0)] ;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.userImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset((CGRect){CGPointZero, self.profileImageSize}, -1.0, -1.0)] CGPath];
}

#pragma mark - MSInstagramPhotoCell

- (void)setPhoto:(MSInstagramPhoto *)photo
{
    [super setPhoto:photo];
    self.userLabel.text = [self.userLabel.text uppercaseString];
}

@end

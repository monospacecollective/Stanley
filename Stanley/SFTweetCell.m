//
//  SFTweetCell.m
//  Stanley
//
//  Created by Eric Horacek on 3/13/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFTweetCell.h"
#import "SFStyleManager.h"

@implementation SFTweetCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        self.user.backgroundColor = [UIColor clearColor];
        self.user.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.user.font = [[SFStyleManager sharedManager] titleFontOfSize:17.0];
        self.user.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.user.layer.shadowRadius = 2.0;
        self.user.layer.shadowOpacity = 1.0;
        self.user.layer.shadowOffset = CGSizeZero;
        self.user.layer.masksToBounds = NO;
        
        self.userImageView.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];
        self.userImageView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.3] CGColor];
        self.userImageView.layer.borderWidth = 1.0;
        self.userImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.userImageView.layer.shadowRadius = 0.0;
        self.userImageView.layer.shadowOpacity = 1.0;
        self.userImageView.layer.shadowOffset = CGSizeZero;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.userImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset((CGRect){CGPointZero, self.profileImageSize}, -1.0, -1.0)] CGPath];
}

#pragma mark - MSTweetCell

- (void)setTweet:(MSTweet *)tweet
{
    [super setTweet:tweet];
    self.user.text = [self.user.text uppercaseString];
}

@end

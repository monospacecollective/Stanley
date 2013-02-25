//
//  SFEventCollectionViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFEventCollectionViewCell.h"
#import "SFStyleManager.h"
#import "Event.h"

@interface SFEventCollectionViewCell ()

+ (UIFont *)titleFont;
+ (UIFont *)detailFont;
+ (UIFont *)iconFont;

+ (CGFloat)contentMargin;
+ (UIEdgeInsets)padding;

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation SFEventCollectionViewCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
     
        self.contentView.backgroundColor = [[SFStyleManager sharedManager] secondaryViewBackgroundColor];
        
        self.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.1] CGColor];
        self.layer.borderWidth = 1.0;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 0.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeZero;
        
        self.shadowView = [UIView new];
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.shadowView.layer.shadowRadius = 3.0;
        self.shadowView.layer.shadowOpacity = 0.5;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        [self insertSubview:self.shadowView belowSubview:self.contentView];
        
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.title.font = self.class.titleFont;
        self.title.numberOfLines = 0;
        self.title.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.title.layer.shadowRadius = 2.0;
        self.title.layer.shadowOpacity = 1.0;
        self.title.layer.shadowOffset = CGSizeZero;
        self.title.layer.masksToBounds = NO;
        [self.contentView addSubview:self.title];
        
        self.time = [UILabel new];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.time.font = self.class.detailFont;
        self.time.numberOfLines = 0;
        self.time.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.time.layer.shadowRadius = 0.0;
        self.time.layer.shadowOpacity = 1.0;
        self.time.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.time.layer.masksToBounds = NO;
        [self.contentView addSubview:self.time];
        
        self.location = [UILabel new];
        self.location.backgroundColor = [UIColor clearColor];
        self.location.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.location.font = self.class.detailFont;
        self.location.numberOfLines = 0;
        self.location.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.location.layer.shadowRadius = 0.0;
        self.location.layer.shadowOpacity = 1.0;
        self.location.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.location.layer.masksToBounds = NO;
        [self.contentView addSubview:self.location];
        
        self.detail = [UILabel new];
        self.detail.backgroundColor = [UIColor clearColor];
        self.detail.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.detail.font = self.class.detailFont;
        self.detail.numberOfLines = 0;
        self.detail.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.detail.layer.shadowRadius = 0.0;
        self.detail.layer.shadowOpacity = 1.0;
        self.detail.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.detail.layer.masksToBounds = NO;
        [self.contentView addSubview:self.detail];
        
        self.timeIcon = [UILabel new];
        self.timeIcon.backgroundColor = [UIColor clearColor];
        self.timeIcon.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.timeIcon.font = self.class.iconFont;
        self.timeIcon.numberOfLines = 0;
        self.timeIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.timeIcon.layer.shadowRadius = 0.0;
        self.timeIcon.layer.shadowOpacity = 1.0;
        self.timeIcon.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.timeIcon.layer.masksToBounds = NO;
        self.timeIcon.text = @"\U000023F2";
        [self.contentView addSubview:self.timeIcon];
        
        self.locationIcon = [UILabel new];
        self.locationIcon.backgroundColor = [UIColor clearColor];
        self.locationIcon.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.locationIcon.font = self.class.iconFont;
        self.locationIcon.numberOfLines = 0;
        self.locationIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.locationIcon.layer.shadowRadius = 0.0;
        self.locationIcon.layer.shadowOpacity = 1.0;
        self.locationIcon.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.locationIcon.layer.masksToBounds = NO;
        self.locationIcon.text = @"\U0000E6D0";
        [self.contentView addSubview:self.locationIcon];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    self.shadowView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    
    CGSize maxTitleSize = CGRectInset(self.contentView.frame, self.class.padding.left, self.class.padding.top).size;
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:maxTitleSize lineBreakMode:self.title.lineBreakMode];
    CGRect titleFrame = self.title.frame;
    titleFrame.size = titleSize;
    titleFrame.origin.x = self.class.padding.left;
    titleFrame.origin.y = self.class.padding.top;
    self.title.frame = titleFrame;
    
    [self.timeIcon sizeToFit];
    CGRect timeIconFrame = self.timeIcon.frame;
    timeIconFrame.origin.x = self.class.padding.left;
    timeIconFrame.origin.y = (CGRectGetMaxY(titleFrame) + self.class.contentMargin);
    self.timeIcon.frame = timeIconFrame;
    
    CGSize maxTimeSize = CGSizeMake((CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.timeIcon.frame) - self.class.padding.right), CGFLOAT_MAX);
    CGSize timeSize = [self.time.text sizeWithFont:self.time.font constrainedToSize:maxTimeSize];
    CGRect timeFrame = self.time.frame;
    timeFrame.size = timeSize;
    timeFrame.origin.x = (CGRectGetMaxX(self.timeIcon.frame) + self.class.contentMargin);
    timeFrame.origin.y = (CGRectGetMaxY(titleFrame) + self.class.contentMargin - 2.0);
    self.time.frame = timeFrame;
    
    [self.locationIcon sizeToFit];
    CGRect locationIconFrame = self.locationIcon.frame;
    locationIconFrame.origin.x = self.class.padding.left;
    locationIconFrame.origin.y = (CGRectGetMaxY(timeFrame) + self.class.contentMargin);
    self.locationIcon.frame = locationIconFrame;
    
    CGSize maxLocationSize = CGSizeMake((CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.locationIcon.frame) - self.class.padding.right), CGFLOAT_MAX);
    CGSize locationSize = [self.location.text sizeWithFont:self.location.font constrainedToSize:maxLocationSize];
    CGRect locationFrame = self.location.frame;
    locationFrame.size = locationSize;
    locationFrame.origin.x = (CGRectGetMaxX(self.locationIcon.frame) + self.class.contentMargin);
    locationFrame.origin.y = (CGRectGetMaxY(timeFrame) + self.class.contentMargin - 1.0);
    self.location.frame = locationFrame;
    
    CGFloat titleDetailMargin = 8.0;
    
    CGSize maxDetailSize = CGSizeMake((CGRectGetWidth(self.contentView.frame) - self.class.padding.left - self.class.padding.right), CGRectGetHeight(self.contentView.frame) - CGRectGetMaxY(locationFrame) - titleDetailMargin - self.class.padding.bottom);
    CGSize detailSize = [self.detail.text sizeWithFont:self.detail.font constrainedToSize:maxDetailSize];
    CGRect detailFrame = self.detail.frame;
    detailFrame.size = detailSize;
    detailFrame.origin.x = self.class.padding.left;
    detailFrame.origin.y = (CGRectGetMaxY(locationFrame) + titleDetailMargin);
    self.detail.frame = detailFrame;
    
    CGFloat maxY = (CGRectGetHeight(self.contentView.frame) - self.class.padding.bottom);
    
    // If the time label is off the bottom, remove it
    if (CGRectGetMaxY(self.time.frame) > maxY) {
        self.time.frame = CGRectZero;
        self.timeIcon.frame = CGRectZero;
    }

    // If the time location is off the bottom, remove it
    if (CGRectGetMaxY(self.location.frame) > maxY) {
        self.location.frame = CGRectZero;
        self.locationIcon.frame = CGRectZero;
    }
    
    // If the detail is off the bottom, remove it
    if (CGRectGetMinY(self.detail.frame) > maxY) {
        self.detail.frame = CGRectZero;
    }
}

#pragma mark - SFEventCollectionViewCell

- (void)setEvent:(Event *)event
{
    _event = event;
    self.title.text = [event.name uppercaseString];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"h:mm a";
    NSString *timeString = [NSString stringWithFormat:@"%@ – %@", [dateFormatter stringFromDate:event.start], [dateFormatter stringFromDate:event.end]];
    self.time.text = timeString;
    
    self.location.text = @"Event Location";
    self.detail.text = event.detail;
    
    [self setNeedsLayout];
}

+ (CGFloat)contentMargin
{
    return 5.0;
}

+ (UIEdgeInsets)padding
{
    CGFloat padding = 15.0;
    return UIEdgeInsetsMake(padding, padding, padding, padding);
}

+ (UIFont *)titleFont
{
    return [[SFStyleManager sharedManager] titleFontOfSize:17.0];
}

+ (UIFont *)detailFont
{
    return [[SFStyleManager sharedManager] detailFontOfSize:14.0];
}

+ (UIFont *)iconFont
{
    return [[SFStyleManager sharedManager] symbolSetFontOfSize:14.0];
}

@end

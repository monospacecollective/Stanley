//
//  SFEventCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFEventCell.h"
#import "SFStyleManager.h"
#import "SFEvent.h"
#import "SFLocation.h"
#import "SFCollectionCellBackgroundView.h"

//#define LAYOUT_DEBUG

@interface SFEventCell ()

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation SFEventCell

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
        self.title.numberOfLines = 0;
        self.title.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.title.layer.shadowRadius = 1.0;
        self.title.layer.shadowOpacity = 1.0;
        self.title.layer.shadowOffset = CGSizeZero;
        self.title.layer.masksToBounds = NO;
        [self.contentView addSubview:self.title];
        
        self.time = [UILabel new];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.time.numberOfLines = 0;
        self.time.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.time.layer.shadowRadius = 1.0;
        self.time.layer.shadowOpacity = 1.0;
        self.time.layer.shadowOffset = CGSizeZero;
        self.time.layer.masksToBounds = NO;
        [self.contentView addSubview:self.time];
        
        self.location = [UILabel new];
        self.location.backgroundColor = [UIColor clearColor];
        self.location.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.location.numberOfLines = 0;
        self.location.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.location.layer.shadowRadius = 1.0;
        self.location.layer.shadowOpacity = 1.0;
        self.location.layer.shadowOffset = CGSizeZero;
        self.location.layer.masksToBounds = NO;
        [self.contentView addSubview:self.location];
        
        self.detail = [UILabel new];
        self.detail.backgroundColor = [UIColor clearColor];
        self.detail.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.detail.font = [[SFStyleManager sharedManager] detailFontOfSize:12.0];
        self.detail.numberOfLines = 0;
        self.detail.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.detail.layer.shadowRadius = 0.0;
        self.detail.layer.shadowOpacity = 1.0;
        self.detail.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.detail.layer.masksToBounds = NO;
        [self.contentView addSubview:self.detail];
        
        self.favoriteIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFFilmCellFavoriteIndicator"]];
        self.favoriteIndicator.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.favoriteIndicator];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    self.shadowView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    
    UIEdgeInsets padding = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0) : UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0));
    CGFloat contentMargin = 5.0;
    
    // Sizing to account for favorite label
    CGSize maxTitleSize = CGRectInset(self.contentView.frame, padding.left, padding.top).size;
    CGSize titleSize = [self.title sizeThatFits:maxTitleSize];
    CGRect titleFrame = self.title.frame;
    titleFrame.size.width = maxTitleSize.width;
    titleFrame.size.height = fminf(titleSize.height, maxTitleSize.height);
    titleFrame.origin.x = padding.left;
    titleFrame.origin.y = padding.top;
    self.title.frame = titleFrame;

    CGSize maxTimeSize = CGSizeMake(CGRectGetWidth(self.contentView.frame) - padding.left - padding.right, CGFLOAT_MAX);
    CGSize timeSize = [self.time sizeThatFits:maxTimeSize];
    CGRect timeFrame = self.time.frame;
    timeFrame.size = timeSize;
    timeFrame.origin.x = padding.left;
    timeFrame.origin.y = (CGRectGetMaxY(titleFrame) + contentMargin);
    self.time.frame = timeFrame;
    
    CGSize maxLocationSize = CGSizeMake((CGRectGetWidth(self.contentView.frame) - padding.left - padding.right), CGFLOAT_MAX);
    CGSize locationSize = [self.location sizeThatFits:maxLocationSize];
    CGRect locationFrame = self.location.frame;
    locationFrame.size = locationSize;
    locationFrame.origin.x = padding.left;
    locationFrame.origin.y = (CGRectGetMaxY(timeFrame) + contentMargin);
    self.location.frame = locationFrame;
    
    CGSize maxDetailSize = CGSizeMake((CGRectGetWidth(self.contentView.frame) - padding.left - padding.right), CGRectGetHeight(self.contentView.frame) - CGRectGetMaxY(locationFrame) - contentMargin - padding.bottom);
    CGSize detailSize = [self.detail sizeThatFits:maxDetailSize];
    CGRect detailFrame;
    detailFrame.size.width = maxDetailSize.width;
    detailFrame.size.height = fminf(detailSize.height, maxDetailSize.height);
    detailFrame.origin.x = padding.left;
    detailFrame.origin.y = (CGRectGetMaxY(locationFrame) + contentMargin);
    self.detail.frame = detailFrame;
    
    CGFloat maxY = (CGRectGetHeight(self.contentView.frame) - padding.bottom - 5.0);
    
    // If the time label is off the bottom, remove it
    if (CGRectGetMaxY(self.time.frame) > maxY) {
        self.time.frame = CGRectZero;
    }
    
    // If the time location is off the bottom, remove it
    if (CGRectGetMaxY(self.location.frame) > maxY) {
        self.location.frame = CGRectZero;
    }
    
    // If the detail is off the bottom, remove it
    if (CGRectGetMinY(self.detail.frame) > maxY) {
        self.detail.frame = CGRectZero;
    }
    
    CGRect favoriteIndicatorFrame = self.favoriteIndicator.frame;
    favoriteIndicatorFrame.origin.x = (CGRectGetWidth(self.contentView.frame) - CGRectGetWidth(favoriteIndicatorFrame));
    self.favoriteIndicator.frame = favoriteIndicatorFrame;
}

#pragma mark - SFEventCell

- (void)setEvent:(SFEvent *)event
{
    _event = event;
    
    self.favoriteIndicator.hidden = ![event.favorite boolValue];
    
    static NSMutableParagraphStyle *paragaphStyle;
    static NSDateFormatter *dateFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paragaphStyle = [NSMutableParagraphStyle new];
        paragaphStyle.hyphenationFactor = 1.0;
        paragaphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"h:mm";
    });
    
    // Title
    NSString *titleString = [event.name uppercaseString];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:titleString attributes: @{
        NSFontAttributeName : [[SFStyleManager sharedManager] titleFontOfSize:15.0 condensed:YES oblique:NO],
    }];
    [title addAttribute:NSParagraphStyleAttributeName value:paragaphStyle range:NSMakeRange(0, title.string.length)];
    self.title.attributedText = title;
    
    NSString *timeString = [NSString stringWithFormat:@"%@–%@", [dateFormatter stringFromDate:event.start], [dateFormatter stringFromDate:event.end]];
    NSMutableAttributedString *time = [[NSMutableAttributedString alloc] initWithString:timeString attributes: @{
        NSFontAttributeName : [[SFStyleManager sharedManager] titleFontOfSize:14.0 condensed:YES oblique:YES],
    }];
    [time addAttribute:NSParagraphStyleAttributeName value:paragaphStyle range:NSMakeRange(0, time.string.length)];
    self.time.attributedText = time;
    
    NSString *locationString = ((event.location.name && ![event.location.name isEqualToString:@""]) ? [NSString stringWithFormat:@"%@", event.location.name] : @"No Location");
    NSMutableAttributedString *location = [[NSMutableAttributedString alloc] initWithString:locationString attributes: @{
        NSFontAttributeName : [[SFStyleManager sharedManager] titleFontOfSize:14.0 condensed:YES oblique:YES],
    }];
    [location addAttribute:NSParagraphStyleAttributeName value:paragaphStyle range:NSMakeRange(0, location.string.length)];
    self.location.attributedText = location;
    
    NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] initWithString:event.detail attributes: @{
        NSFontAttributeName : [[SFStyleManager sharedManager] detailFontOfSize:14.0 condensed:YES oblique:NO]
    }];
    [detail addAttribute:NSParagraphStyleAttributeName value:paragaphStyle range:NSMakeRange(0, detail.string.length)];
    self.detail.attributedText = detail;
    
    [self setNeedsLayout];
}

@end

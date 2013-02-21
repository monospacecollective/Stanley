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
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    self.shadowView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(self.contentView.frame, -2.0, -2.0)] CGPath];
    
    CGSize maxContentSize = CGRectInset(self.contentView.frame, self.class.padding.left, self.class.padding.right).size;
    CGFloat contentPadding = 4.0;
    
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:maxContentSize lineBreakMode:self.title.lineBreakMode];
    CGRect titleFrame = self.title.frame;
    titleFrame.size = titleSize;
    titleFrame.origin.x = self.class.padding.left;
    titleFrame.origin.y = self.class.padding.top;
    self.title.frame = titleFrame;
    
    CGSize timeSize = [self.time.text sizeWithFont:self.time.font forWidth:maxContentSize.width lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect timeFrame = self.time.frame;
    timeFrame.size = timeSize;
    timeFrame.origin.x = self.class.padding.left;
    timeFrame.origin.y = (CGRectGetMaxY(titleFrame) + contentPadding);
    self.time.frame = timeFrame;
    if (CGRectGetMaxY(timeFrame) > (self.class.padding.top + maxContentSize.height)) {
        self.time.frame = CGRectZero;
    } else {
        self.time.frame = timeFrame;
    }
    
    CGSize locationSize = [self.location.text sizeWithFont:self.location.font forWidth:maxContentSize.width lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect locationFrame = self.location.frame;
    locationFrame.size = locationSize;
    locationFrame.origin.x = self.class.padding.left;
    locationFrame.origin.y = (CGRectGetMaxY(timeFrame) + contentPadding);
    if (CGRectGetMaxY(locationFrame) > (self.class.padding.top + maxContentSize.height)) {
        self.location.frame = CGRectZero;
    } else {
        self.location.frame = locationFrame;
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
    
    [self setNeedsLayout];
}

+ (CGFloat)cellSpacing
{
    return 4.0;
}

+ (UIEdgeInsets)padding
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0) : UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0));
}

+ (UIFont *)titleFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 18.0 : 17.0);
    return [[SFStyleManager sharedManager] titleFontOfSize:fontSize];
}

+ (UIFont *)detailFont
{
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 15.0 : 14.0);
    return [[SFStyleManager sharedManager] detailFontOfSize:fontSize];
}

@end

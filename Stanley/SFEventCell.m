//
//  SFEventCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFEventCell.h"
#import "SFStyleManager.h"
#import "Event.h"
#import "Location.h"

//#define LAYOUT_DEBUG

@interface SFEventCell ()

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) CAGradientLayer *contentMaskGradient;

@end

@implementation SFEventCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        self.contentView.layer.masksToBounds = YES;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 0.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowOffset = CGSizeZero;
        
        self.shadowView = [UIView new];
        self.shadowView.backgroundColor = [[SFStyleManager sharedManager] secondaryViewBackgroundColor];
        self.shadowView.layer.masksToBounds = NO;
        self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.shadowView.layer.shadowRadius = 3.0;
        self.shadowView.layer.shadowOpacity = 0.5;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.shadowView.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.1] CGColor];
        self.shadowView.layer.borderWidth = 1.0;
        [self insertSubview:self.shadowView belowSubview:self.contentView];
        
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [[SFStyleManager sharedManager] primaryTextColor];
        self.title.font = [[SFStyleManager sharedManager] titleFontOfSize:17.0];
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
        self.time.font = [[SFStyleManager sharedManager] detailFontOfSize:14.0];
        self.time.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.time.layer.shadowRadius = 0.0;
        self.time.layer.shadowOpacity = 1.0;
        self.time.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.time.layer.masksToBounds = NO;
        [self.contentView addSubview:self.time];
        
        self.location = [UILabel new];
        self.location.backgroundColor = [UIColor clearColor];
        self.location.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.location.font = [[SFStyleManager sharedManager] detailFontOfSize:14.0];
        self.location.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.location.layer.shadowRadius = 0.0;
        self.location.layer.shadowOpacity = 1.0;
        self.location.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.location.layer.masksToBounds = NO;
        [self.contentView addSubview:self.location];
        
        self.detail = [UILabel new];
        self.detail.backgroundColor = [UIColor clearColor];
        self.detail.textColor = [[SFStyleManager sharedManager] secondaryTextColor];
        self.detail.font = [[SFStyleManager sharedManager] detailFontOfSize:14.0];
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
        self.timeIcon.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:14.0];
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
        self.locationIcon.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:14.0];
        self.locationIcon.numberOfLines = 0;
        self.locationIcon.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.locationIcon.layer.shadowRadius = 0.0;
        self.locationIcon.layer.shadowOpacity = 1.0;
        self.locationIcon.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.locationIcon.layer.masksToBounds = NO;
        self.locationIcon.text = @"\U0000E6D0";
        [self.contentView addSubview:self.locationIcon];
        
        self.favoriteIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFFilmCellFavoriteIndicator"]];
        self.favoriteIndicator.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.favoriteIndicator];
        
        self.contentMaskGradient = [CAGradientLayer layer];
        self.contentMaskGradient.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]];
        self.contentMaskGradient.locations = @[@(0.9), @(1.0)];
        self.contentView.layer.mask = self.contentMaskGradient;
        
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        self.timeIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.time.translatesAutoresizingMaskIntoConstraints = NO;
        self.locationIcon.translatesAutoresizingMaskIntoConstraints = NO;
        self.location.translatesAutoresizingMaskIntoConstraints = NO;
        self.detail.translatesAutoresizingMaskIntoConstraints = NO;
        self.favoriteIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
#if defined(LAYOUT_DEBUG)
        self.title.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.time.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.location.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.detail.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.locationIcon.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.timeIcon.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect contentFrame = (CGRect){CGPointZero, self.frame.size};
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(contentFrame, -2.0, -2.0)] CGPath];
    self.shadowView.frame = contentFrame;
    self.shadowView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(contentFrame, -2.0, -2.0)] CGPath];
    
    self.contentMaskGradient.frame = (CGRect){CGPointZero, self.contentView.frame.size};
}

#pragma mark - SFEventCell

- (void)setEvent:(Event *)event
{
    _event = event;
    self.title.text = [event.name uppercaseString];
    self.favoriteIndicator.hidden = ![event.favorite boolValue];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"h:mm a";
    NSString *timeString = [NSString stringWithFormat:@"%@ – %@", [dateFormatter stringFromDate:event.start], [dateFormatter stringFromDate:event.end]];
    self.time.text = timeString;
    
    self.location.text = ((event.location.name && ![event.location.name isEqualToString:@""]) ? event.location.name : @"No Location");
    self.detail.text = [[event.detail stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    CGFloat padding = (self.frame.size.width <= 150.0) ? 10.0 : 15.0;
    
    self.title.preferredMaxLayoutWidth = (CGRectGetWidth(self.contentView.frame) - (padding * 2.0));
    CGSize titleSize = [self.title.text sizeWithFont:self.title.font constrainedToSize:CGSizeMake(self.title.preferredMaxLayoutWidth, CGFLOAT_MAX) lineBreakMode:self.title.lineBreakMode];
    
    self.detail.preferredMaxLayoutWidth = (CGRectGetWidth(self.contentView.frame) - (padding * 2.0));
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    NSDictionary *views = @{ @"title" : self.title , @"timeIcon" : self.timeIcon , @"time" : self.time, @"locationIcon" : self.locationIcon , @"location" : self.location, @"detail" : self.detail };
    NSDictionary *metrics = @{ @"padding" : @(padding) , @"contentMargin" : @(6.0) , @"titleHeight" : @(titleSize.height) , @"minDetailHeight" : @(self.detail.font.lineHeight), @"iconWidth" : @(15.0) };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[title(==titleHeight)]-contentMargin-[time(>=minDetailHeight)]-contentMargin-[location(>=minDetailHeight)]-contentMargin-[detail(>=0)]" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-contentMargin-[timeIcon(>=minDetailHeight)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[time]-contentMargin-[locationIcon(>=minDetailHeight)]" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[title]->=padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[timeIcon(==iconWidth)]-contentMargin-[time]->=padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[locationIcon(==iconWidth)]-contentMargin-[location]->=padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[detail]->=padding-|" options:0 metrics:metrics views:views]];
    
    [self.favoriteIndicator pinToSuperviewEdges:(JRTViewPinTopEdge | JRTViewPinRightEdge) inset:0];
    
    [self setNeedsLayout];
}

@end

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
        
        self.backgroundView = [[SFCollectionCellBackgroundView alloc] init];
        
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
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.title];
        
        self.time = [UILabel new];
        [[SFStyleManager sharedManager] styleDetailLabel:self.time autolayout:YES];
        [self.contentView addSubview:self.time];
        
        self.location = [UILabel new];
        [[SFStyleManager sharedManager] styleDetailLabel:self.location autolayout:YES];
        [self.contentView addSubview:self.location];
        
        self.detail = [UILabel new];
        [[SFStyleManager sharedManager] styleDetailLabel:self.detail autolayout:YES];
        self.detail.numberOfLines = 0;
        [self.contentView addSubview:self.detail];
        
        self.timeIcon = [UILabel new];
        [[SFStyleManager sharedManager] styleDetailIconLabel:self.timeIcon autolayout:YES];
        self.timeIcon.text = @"\U000023F2";
        [self.contentView addSubview:self.timeIcon];
        
        self.locationIcon = [UILabel new];
        [[SFStyleManager sharedManager] styleDetailIconLabel:self.locationIcon autolayout:YES];
        self.locationIcon.text = @"\U0000E6D0";
        [self.contentView addSubview:self.locationIcon];
        
        self.favoriteIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFFilmCellFavoriteIndicator"]];
        self.favoriteIndicator.backgroundColor = [UIColor clearColor];
        self.favoriteIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.favoriteIndicator];
        
        self.contentMaskGradient = [CAGradientLayer layer];
        self.contentMaskGradient.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]];
        self.contentMaskGradient.locations = @[@(0.9), @(1.0)];
        self.contentView.layer.mask = self.contentMaskGradient;
        
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

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    NSDictionary *views = @{ @"title" : self.title , @"timeIcon" : self.timeIcon , @"time" : self.time, @"locationIcon" : self.locationIcon , @"location" : self.location, @"detail" : self.detail };
    NSDictionary *metrics = @{ @"padding" : @(14.0) , @"contentMargin" : @(6.0) , @"minTitleHeight" : @(self.title.font.lineHeight) , @"minDetailHeight" : @(self.detail.font.lineHeight), @"iconWidth" : @(15.0) };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[title(>=minTitleHeight)]-contentMargin-[time(>=minDetailHeight)]-contentMargin-[location(>=minDetailHeight)]-contentMargin-[detail]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-contentMargin-[timeIcon(>=minDetailHeight)]" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[time]-contentMargin-[locationIcon(>=minDetailHeight)]" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[title]->=padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[timeIcon(==iconWidth)]-contentMargin-[time]->=padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[locationIcon(==iconWidth)]-contentMargin-[location]->=padding-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[detail]->=padding-|" options:0 metrics:metrics views:views]];
    
    [self.favoriteIndicator pinToSuperviewEdges:(JRTViewPinTopEdge | JRTViewPinRightEdge) inset:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Changing the frame is animated by default, so we have to disable actions
    [CATransaction setDisableActions:YES];
    self.contentMaskGradient.frame = (CGRect){CGPointZero, self.contentMaskGradient.superlayer.frame.size};
    [CATransaction setDisableActions:NO];
}

#pragma mark - SFEventCell

- (void)setEvent:(SFEvent *)event
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
    
    self.title.preferredMaxLayoutWidth = (CGRectGetWidth(self.contentView.frame) - (14.0 * 2.0));
    self.detail.preferredMaxLayoutWidth = (CGRectGetWidth(self.contentView.frame) - (14.0 * 2.0));
    
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

@end

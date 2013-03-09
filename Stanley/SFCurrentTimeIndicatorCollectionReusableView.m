//
//  SFCurrentTimeIndicatorCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFCurrentTimeIndicatorCollectionReusableView.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@interface SFCurrentTimeIndicatorCollectionReusableView ()

@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, retain) NSTimer *minuteTimer;

@end

@implementation SFCurrentTimeIndicatorCollectionReusableView

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"SFCurrentTimeIndicatorBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        self.backgroundImage = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:self.backgroundImage];
        
        self.time = [UILabel new];
        self.time.backgroundColor = [UIColor clearColor];
        self.time.textColor = [UIColor whiteColor];
        self.time.font = [[SFStyleManager sharedManager] detailFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 17.0 : 15.0)];
        self.time.textAlignment = NSTextAlignmentCenter;
        self.time.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.time.layer.shadowRadius = 0.0;
        self.time.layer.shadowOpacity = 1.0;
        self.time.layer.shadowOffset = CGSizeMake(0.0, -1.0);
        self.time.layer.masksToBounds = NO;
        [self addSubview:self.time];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:oneMinuteInFuture];
        NSDate *nextMinuteBoundary = [calendar dateFromComponents:components];
        
        self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:self selector:@selector(minuteTick:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];
        
        [self updateTime];
        
#if defined(LAYOUT_DEBUG)
        self.time.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        self.backgroundImage.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
#endif
    }
    return self;
}

- (void)removeFromSuperview
{
    [self.minuteTimer invalidate];
    self.minuteTimer = nil;
    [super removeFromSuperview];
}

#pragma mark - SFCurrentTimeIndicatorCollectionReusableView

- (void)minuteTick:(id)sender
{
    [self updateTime];
}

- (void)updateTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"h:mm"];
    self.time.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat backgroundImageInset = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? -4.0 : -2.0);
    self.backgroundImage.frame = CGRectInset((CGRect){CGPointZero, self.frame.size}, backgroundImageInset, 0.0);
    
    [self.time sizeToFit];
    CGRect timeFrame = self.time.frame;
    timeFrame.origin.x = nearbyintf((CGRectGetWidth(self.frame) / 2.0) - (CGRectGetWidth(timeFrame) / 2.0));
    timeFrame.origin.y = (nearbyintf((CGRectGetHeight(self.frame) / 2.0) - (CGRectGetHeight(timeFrame) / 2.0)) - 1.0);
    self.time.frame = timeFrame;
}

@end

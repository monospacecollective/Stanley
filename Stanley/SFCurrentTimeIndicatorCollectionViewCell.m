//
//  SFCurrentTimeIndicatorCollectionViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFCurrentTimeIndicatorCollectionViewCell.h"
#import "SFStyleManager.h"

@interface SFCurrentTimeIndicatorCollectionViewCell ()

@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, retain) NSTimer *minuteTimer;

@end

@implementation SFCurrentTimeIndicatorCollectionViewCell

- (void)dealloc
{
    [self.minuteTimer invalidate];
    self.minuteTimer = nil;
}

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
        self.time.font = [[SFStyleManager sharedManager] detailFontOfSize:17.0];
        self.time.textAlignment = UITextAlignmentCenter;
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
    }
    return self;
}

-(void)minuteTick:(id)sender
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
    self.backgroundImage.frame = (CGRect){{4.0, 0.0}, self.frame.size};
    self.time.frame = (CGRect){{4.0, 0.0}, self.frame.size};
}

@end

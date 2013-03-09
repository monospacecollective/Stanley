//
//  SFDayColumnHeaderCollectionReusableView.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFDayColumnHeaderCollectionReusableView.h"
#import "SFStyleManager.h"

//#define LAYOUT_DEBUG

@implementation SFDayColumnHeaderCollectionReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.todayBackground = [UIView new];
        self.todayBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        self.todayBackground.layer.shadowColor = [[UIColor colorWithWhite:1.0 alpha:0.1] CGColor];
        self.todayBackground.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.todayBackground.layer.shadowOpacity = 1.0;
        self.todayBackground.layer.shadowRadius = 0.0;
        self.todayBackground.hidden = YES;
        [self addSubview:self.todayBackground];
        
        self.day = [UILabel new];
        self.day.backgroundColor = [UIColor clearColor];
        self.day.textColor = [UIColor colorWithHexString:@"aaaaaa"];
        self.day.font = [[SFStyleManager sharedManager] detailFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 15.0 : 18.0)];
        self.day.textAlignment = NSTextAlignmentCenter;
        self.day.shadowColor = [UIColor blackColor];
        self.day.shadowOffset = CGSizeMake(0.0, -1.0);
        [self addSubview:self.day];
        
#if defined(LAYOUT_DEBUG)
        self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        self.layer.borderColor = [[UIColor blueColor] CGColor];
        self.layer.borderWidth = 1.0;
#endif
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.day sizeToFit];
    CGRect dayFrame = self.day.frame;
    dayFrame.size.width = (CGRectGetWidth(self.frame) - (self.class.padding.width * 2.0));
    dayFrame.origin.x = self.class.padding.width;
    dayFrame.origin.y = (nearbyintf((CGRectGetHeight(self.frame) / 2.0) - (CGRectGetHeight(dayFrame) / 2.0)) + 3.0);
    self.day.frame = dayFrame;
    
    CGFloat todayBackgroundHorizontalInset = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 0.0 : 8.0);
    CGFloat todayBackgroundVerticalInset = 8.0;
    self.todayBackground.frame = CGRectInset((CGRect){CGPointZero, self.frame.size}, todayBackgroundHorizontalInset, todayBackgroundVerticalInset);
}

- (void)setToday:(BOOL)today
{
    _today = today;
    self.todayBackground.hidden = !today;
    if (today) {
        self.day.textColor = [UIColor whiteColor];
        self.day.shadowOffset = CGSizeMake(0.0, 1.0);
    } else {
        self.day.textColor = [UIColor colorWithHexString:@"aaaaaa"];
        self.day.shadowOffset = CGSizeMake(0.0, -1.0);
    }
}

+ (CGSize)padding
{
    return CGSizeMake(0.0, 8.0);
}

@end

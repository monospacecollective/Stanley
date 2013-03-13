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
        self.todayBackground.backgroundColor = [[UIColor colorWithHexString:@"631414"] colorWithNoiseWithOpacity:0.1 andBlendMode:kCGBlendModeMultiply];
        self.todayBackground.layer.shadowColor = [[UIColor colorWithWhite:1.0 alpha:0.1] CGColor];
        self.todayBackground.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.todayBackground.layer.shadowOpacity = 1.0;
        self.todayBackground.layer.shadowRadius = 0.0;
        self.todayBackground.layer.borderColor = [[UIColor blackColor] CGColor];
        self.todayBackground.layer.borderWidth = 2.0;
        [self addSubview:self.todayBackground];
        
        self.day = [UILabel new];
        self.day.backgroundColor = [UIColor clearColor];
        self.day.textColor = [UIColor colorWithHexString:@"aaaaaa"];
        self.day.font = [[SFStyleManager sharedManager] detailFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 15.0 : 18.0)];
        self.day.textAlignment = NSTextAlignmentCenter;
        self.day.shadowColor = [UIColor blackColor];
        self.day.shadowOffset = CGSizeMake(0.0, -1.0);
        [self addSubview:self.day];
        
        self.day.translatesAutoresizingMaskIntoConstraints = NO;
        [self.day pinToSuperviewEdgesWithInset:UIEdgeInsetsMake(15.0, 6.0, 10.0, 6.0)];
        
        self.todayBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [self.todayBackground pinToSuperviewEdgesWithInset:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0) : UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0))];
        
#if defined(LAYOUT_DEBUG)
        self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        self.day.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        self.todayBackground.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        self.layer.borderColor = [[UIColor blueColor] CGColor];
        self.layer.borderWidth = 1.0;
#endif
    }
    return self;
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

@end

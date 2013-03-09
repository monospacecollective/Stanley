//
//  SFMasterTableViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMasterCell.h"
#import "SFStyleManager.h"

@implementation SFMasterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.icon = [UILabel new];
        self.icon.backgroundColor = [UIColor clearColor];
        self.icon.font = [[SFStyleManager sharedManager] symbolSetFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24.0 : 20.0)];
        self.icon.textColor = [UIColor whiteColor];
        self.icon.textAlignment = NSTextAlignmentCenter;
        self.icon.shadowColor = [UIColor blackColor];
        self.icon.shadowOffset = CGSizeMake(0.0, -1.0);
        [self.contentView addSubview:self.icon];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat iconOffset = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 48.0 : 42.0);
    self.title.frame = CGRectOffset(self.title.frame, iconOffset, 0.0);
    
    [self.icon sizeToFit];
    CGRect iconFrame = self.icon.frame;
    iconFrame.origin = CGPointMake(0.0, ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 8.0 : 6.0));
    iconFrame.size.width = CGRectGetMinX(self.title.frame);
    self.icon.frame = iconFrame;
}

+ (CGFloat)height
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 52.0 : 44.0);
}

@end

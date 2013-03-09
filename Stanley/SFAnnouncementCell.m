//
//  SFAnnouncementTableViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/15/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFAnnouncementCell.h"
#import "Announcement.h"

@implementation SFAnnouncementCell

- (void)initialize
{
    [super initialize];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.detail.numberOfLines = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleFrame = self.title.frame;
    titleFrame.origin.y = 10.0;
    self.title.frame = titleFrame;
    
    CGRect detailFrame = self.detail.frame;
    detailFrame.origin.y = CGRectGetMaxY(self.title.frame) + 4.0;
    detailFrame.size.height = CGRectGetHeight(self.contentView.frame) - CGRectGetMinY(detailFrame) - 10.0;
    self.detail.frame = detailFrame;
}

- (void)setAnnouncement:(Announcement *)announcement
{
    _announcement = announcement;
    
    self.title.text = [announcement.title uppercaseString];
    self.detail.text = announcement.body;
    
    [self setNeedsLayout];
}

+ (CGFloat)height
{
    return 110.0;
}

@end

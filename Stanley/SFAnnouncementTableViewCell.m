//
//  SFAnnouncementTableViewCell.m
//  Stanley
//
//  Created by Eric Horacek on 2/15/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFAnnouncementTableViewCell.h"
#import "Announcement.h"

@implementation SFAnnouncementTableViewCell

- (void)initialize
{
    [super initialize];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.detailTextLabel.numberOfLines = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.y = 10.0;
    self.textLabel.frame = textLabelFrame;
    
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    detailTextLabelFrame.origin.y = CGRectGetMaxY(self.textLabel.frame) + 4.0;
    detailTextLabelFrame.size.height = CGRectGetHeight(self.contentView.frame) - CGRectGetMinY(detailTextLabelFrame) - 10.0;
    self.detailTextLabel.frame = detailTextLabelFrame;
}

- (void)setAnnouncement:(Announcement *)announcement
{
    _announcement = announcement;
    
    self.textLabel.text = [announcement.title uppercaseString];
    self.detailTextLabel.text = announcement.body;
    
    [self setNeedsLayout];
}

@end

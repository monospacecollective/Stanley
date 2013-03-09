//
//  SFAnnouncementTableViewCell.h
//  Stanley
//
//  Created by Eric Horacek on 2/15/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSSubtitleDetailPlainTableViewCell.h"

@class Announcement;

@interface SFAnnouncementCell : MSSubtitleDetailPlainTableViewCell

@property (nonatomic, weak) Announcement *announcement;

@end

//
//  Announcement.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "Announcement.h"


@implementation Announcement

@dynamic title;
@dynamic body;
@dynamic published;

- (NSDate *)dayPublished
{
    return [self.published beginningOfDay];
}

@end

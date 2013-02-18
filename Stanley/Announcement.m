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

- (NSInteger)dayPublished
{
    NSDateComponents *dayComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self.published];
    return dayComponents.day;
}

@end

//
//  Event.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "Event.h"


@implementation Event

@dynamic name;
@dynamic start;
@dynamic end;
@dynamic detail;

- (NSUInteger)day
{
    NSDateComponents *dayComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self.start];
    return dayComponents.day;
}

@end

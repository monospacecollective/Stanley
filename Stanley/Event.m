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

- (NSDate *)day
{
    return [self.start beginningOfDay];
}

@end

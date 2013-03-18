//
//  SFLocationAnnotation.m
//  Stanley
//
//  Created by Eric Horacek on 2/21/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFLocationAnnotation.h"
#import "SFLocation.h"

@implementation SFLocationAnnotation

- (id)initWithLocation:(SFLocation *)locaation
{
    self = [super init];
    if (self) {
        self.location = locaation;
    }
    return self;
}

- (NSString *)title
{
    return self.location.name;
}

- (NSString *)subtitle
{
    return self.location.detail;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

@end

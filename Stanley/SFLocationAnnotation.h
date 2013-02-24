//
//  SFLocationAnnotation.h
//  Stanley
//
//  Created by Eric Horacek on 2/21/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Location;

@interface SFLocationAnnotation : MKPointAnnotation

@property (nonatomic, weak) Location * location;

- (id)initWithLocation:(Location *)ocation;

- (NSString *)title;
- (NSString *)subtitle;
- (CLLocationCoordinate2D)coordinate;

@end

//
//  Location.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *events;

- (void)openInMapsWithRoute;
- (CLLocationCoordinate2D)coordinate;
- (MKMapItem *)mapItem;

@end

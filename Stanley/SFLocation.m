//
//  SFLocation.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFLocation.h"

@implementation SFLocation

@dynamic remoteID;
@dynamic name;
@dynamic detail;
@dynamic latitude;
@dynamic longitude;
@dynamic events;

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (void)openInMapsWithRoute
{
    // Establish a "block safe self" weak reference to prevent retain cycles in blocks
    __weak typeof(self) blockSelf = self;
    
    BOOL canRouteUsingGoogleMaps = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
    
    void(^routeUsingGoogleMaps)() = ^{
        NSString *mapURLString = [NSString stringWithFormat:@"comgooglemaps://?daddr=%@,%@&saddr=Current%%20Location&directionsmode=driving", blockSelf.latitude, blockSelf.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapURLString]];
    };
    
    void(^routeUsingAppleMaps)() = ^{
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *locationMapItem = blockSelf.mapItem;
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocationMapItem, locationMapItem, nil]
                       launchOptions:[NSDictionary dictionaryWithObject:MKLaunchOptionsDirectionsModeDriving
                                                                 forKey:MKLaunchOptionsDirectionsModeKey]];
    };
    
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {        
        if (canRouteUsingGoogleMaps) {
            routeUsingGoogleMaps();
        } else {
            routeUsingAppleMaps();
        }
    }
}

- (MKMapItem *)mapItem
{
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.name;
    return mapItem;
}

- (NSArray *)sortedEvents
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(location == %@)", self];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

@end

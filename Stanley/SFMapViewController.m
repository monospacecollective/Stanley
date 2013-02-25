//
//  SFMapViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/21/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMapViewController.h"
#import "Location.h"
#import "SFLocationAnnotation.h"

NSString* const SFMapViewPinIdentifier = @"SFMapViewPinIdentifier";

@interface SFMapViewController () <MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)reloadData;
- (void)addLocationAnnotations;
- (void)zoomToAnnotationsAnimated:(BOOL)animated;

@end

@implementation SFMapViewController

- (void)loadView
{
    self.mapView = [[MKMapView alloc] init];
    self.view = self.mapView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [self addLocationAnnotations];
    [self zoomToAnnotationsAnimated:NO];
    
    [self reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self zoomToAnnotationsAnimated:YES];
}

#pragma mark - SFMapViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/locations.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@",[mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Event load failed with error: %@", error);
    }];
}

- (void)addLocationAnnotations
{
    for (Location *location in self.fetchedResultsController.fetchedObjects) {
        SFLocationAnnotation *annotation = [[SFLocationAnnotation alloc] init];
        annotation.location = location;
        [self.mapView addAnnotation:annotation];
    }
}

- (void)zoomToAnnotationsAnimated:(BOOL)animated;
{
    // Zoom in on an enclosing rect of the user's locations
    if (self.mapView.annotations.count > 1) {
        
        // Calculate enclosing rect
        MKMapPoint northEastPoint = MKMapPointForCoordinate([self.mapView.annotations[0] coordinate]);
        MKMapPoint southWestPoint = MKMapPointForCoordinate([self.mapView.annotations[0] coordinate]);
        
        // Iterate through the annotations, building an enclosing rect for all of them (with north east corner and south west corner)
        for (MKPointAnnotation *annotation in self.mapView.annotations) {
            MKMapPoint point = MKMapPointForCoordinate(annotation.coordinate);
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if (point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        
        // If the points are eqivalent, then just zoom in on them as a point
        if (MKMapPointEqualToPoint(northEastPoint, southWestPoint)) {
            
            CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(northEastPoint);
            // Check the validity of the coordinate
            if (CLLocationCoordinate2DIsValid(coordinate)) {
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
                [self.mapView setRegion:region animated:animated];
            }
        }
        // Otherwise we have a rect, build it and zoom on it (keeping paddings)
        else {
            // Build a rect of the locations from our corners
            MKMapRect routeRect = MKMapRectMake(southWestPoint.x,
                                                southWestPoint.y,
                                                (northEastPoint.x - southWestPoint.x),
                                                (northEastPoint.y - southWestPoint.y));
            
            // Calculate edge insets based on screen scale (1.0 or 2.0)
            CGFloat screenScale = [[UIScreen mainScreen] scale];
            CGFloat topInset = 50.0 * screenScale;
            CGFloat sideInset = 20.0 * screenScale;
            CGFloat bottomInset = 10.0 * screenScale;
            
            UIEdgeInsets edgePadding = UIEdgeInsetsMake(topInset, sideInset, bottomInset, sideInset);
            [self.mapView setVisibleMapRect:routeRect edgePadding:edgePadding animated:animated];
        }
    }
    // If there's just one annotation, zoom on it
    else if (self.mapView.annotations.count == 1) {
        CLLocationCoordinate2D coordinate = [self.mapView.annotations[0] coordinate];
        // Check the validity of the coordinate
        if (CLLocationCoordinate2DIsValid(coordinate)) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
            [self.mapView setRegion:region animated:animated];
        }
    }
    // Last of all, try to just zoom on the user location
    else {
        CLLocationCoordinate2D coordinate = self.mapView.userLocation.coordinate;
        // Check the validity of the coordinate and make sure it's not 0.0, 0.0
        if (CLLocationCoordinate2DIsValid(coordinate) && ((coordinate.latitude != 0.0) && (coordinate.longitude != 0.0))) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
            [self.mapView setRegion:region animated:animated];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    Location *location = (Location *)anObject;

    switch (type) {
        case NSFetchedResultsChangeInsert: {
            SFLocationAnnotation *annotation = [[SFLocationAnnotation alloc] init];
            annotation.location = location;
            [self.mapView addAnnotation:annotation];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            break;
        }
        case NSFetchedResultsChangeDelete: {
            NSUInteger annotationIndex = [self.mapView.annotations indexOfObjectPassingTest:^BOOL(id annotation, NSUInteger index, BOOL *stop) {
                return (((SFLocationAnnotation *)annotation).location == location);
            }];
            SFLocationAnnotation *annotation = ((annotationIndex < self.mapView.annotations.count) ? self.mapView.annotations[annotationIndex] : nil);
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    [self zoomToAnnotationsAnimated:NO];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:SFLocationAnnotation.class]) {
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:SFMapViewPinIdentifier];
        
        if (!pinView) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SFMapViewPinIdentifier];
        }
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // TODO: Add button style image
//        UIImage *disclosureIcon = [UIImage imageNamed:@"ERDisclosureIcon"];
//        [rightButton setImage:disclosureIcon forState:UIControlStateNormal];
//        [rightButton setImage:[disclosureIcon darkenedImageWithOverlayAlpha:0.3] forState:UIControlStateHighlighted];
//        [rightButton setFrame:CGRectMake(0.0, 0.0, disclosureIcon.size.width, disclosureIcon.size.height)];
//        rightButton.tag = [self.annotations indexOfObject:annotation];
        pinView.rightCalloutAccessoryView = rightButton;
        
        return pinView;
    } else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
}


@end

//
//  SFMapViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/21/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMapViewController.h"
#import "SFLocation.h"
#import "SFLocationAnnotation.h"
#import "SFStyleManager.h"
#import "SFLocationViewController.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"
#import "SFPopoverToolbar.h"
#import "SFPopoverNavigationBar.h"

NSString* const SFMapViewPinIdentifier = @"SFMapViewPinIdentifier";
NSString* const SFMapViewCurrentLocationIdentifier = @"SFMapViewCurrentLocationIdentifier";

@interface SFMapViewController () <MKMapViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIPopoverController *locationPopoverController;
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
    
    [self.navigationController setToolbarHidden:NO];
    
    __weak typeof(self) weakSelf = self;
    SVSegmentedControl *segmentedControl = [[SFStyleManager sharedManager] styledSegmentedControlWithTitles:@[@"STANDARD", @"SATELLITE"] action:^(NSUInteger newIndex) {
        weakSelf.mapView.mapType = ((newIndex == 0) ? MKMapTypeStandard : MKMapTypeHybrid);
    }];
    UIBarButtonItem *segmentedControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], segmentedControlBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    
    [self addLocationAnnotations];
    [self zoomToAnnotationsAnimated:NO];
    
    [self reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self zoomToAnnotationsAnimated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.locationPopoverController dismissPopoverAnimated:NO];
    
    for (id <MKAnnotation> annotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
}

#pragma mark - SFMapViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/locations.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Event load failed with error: %@", error);
    }];
}

- (void)addLocationAnnotations
{
    for (SFLocation *location in self.fetchedResultsController.fetchedObjects) {
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
            MKMapRect routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, (northEastPoint.x - southWestPoint.x), (northEastPoint.y - southWestPoint.y));
            UIEdgeInsets edgePadding = UIEdgeInsetsMake(100.0, 40.0, 20.0, 40.0);
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
    SFLocation *location = (SFLocation *)anObject;

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
        pinView.canShowCallout = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
        pinView.rightCalloutAccessoryView = [[SFStyleManager sharedManager] styledDisclosureButton];
        return pinView;
    }
    else if ([annotation isKindOfClass:MKUserLocation.class]) {
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:SFMapViewCurrentLocationIdentifier];
        if(pulsingView == nil) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:SFMapViewCurrentLocationIdentifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
        }
        pulsingView.canShowCallout = YES;
        return pulsingView;
    }
    else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:SFLocationAnnotation.class]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            SFLocationViewController *locationController = [[SFLocationViewController alloc] init];
            locationController.location = [(SFLocationAnnotation *)view.annotation location];
            
            __weak typeof (self) weakSelf = self;
            locationController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledCloseBarButtonItemWithAction:^{
                [weakSelf.locationPopoverController dismissPopoverAnimated:YES];
                weakSelf.locationPopoverController = nil;
                for (id <MKAnnotation> annotation in weakSelf.mapView.selectedAnnotations) {
                    [weakSelf.mapView deselectAnnotation:annotation animated:YES];
                }
            }];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFPopoverNavigationBar.class toolbarClass:SFPopoverToolbar.class];
            [navigationController addChildViewController:locationController];
            
            self.locationPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            self.locationPopoverController.popoverBackgroundViewClass = GIKPopoverBackgroundView.class;
            self.locationPopoverController.delegate = self;
            
            CGPoint origin = [self.mapView convertCoordinate:view.annotation.coordinate toPointToView:self.mapView];
            origin.x -= nearbyintf(view.frame.size.width / 2.0);
            origin.y -= view.frame.size.height;
            CGRect frame = (CGRect){origin, view.frame.size};
            
            [self.locationPopoverController presentPopoverFromRect:frame inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    SFLocationViewController *locationController = [[SFLocationViewController alloc] init];
    locationController.location = [(SFLocationAnnotation *)view.annotation location];
    
    __weak typeof (self) weakSelf = self;
    locationController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledCloseBarButtonItemWithAction:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
    [navigationController addChildViewController:locationController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Required to get the popover to dealloc when it's removed
    self.locationPopoverController = nil;
    
    for (id <MKAnnotation> annotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
}

@end

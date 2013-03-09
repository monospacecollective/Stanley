//
//  SFLocationViewController.m
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFLocationViewController.h"
#import "SFStyleManager.h"
#import "Location.h"
#import "SFMapCell.h"
#import "SFWebViewController.h"
#import "SFAppDelegate.h"
#import "SFMapViewController.h"

// Sections
NSString *const SFLocationTableSectionName = @"Name";
NSString *const SFLocationTableSectionDescription = @"Description";
NSString *const SFLocationTableSectionMap = @"Map";
NSString *const SFLocationTableSectionEvents = @"Events";
NSString *const SFLocationTableSectionActions = @"Actions";

// Reuse Identifiers
NSString *const SFLocationReuseIdentifierName = @"Name";
NSString *const SFLocationReuseIdentifierDescription = @"Description";
NSString *const SFLocationReuseIdentifierMap = @"Map";
NSString *const SFLocationReuseIdentifierEvent = @"Event";
NSString *const SFLocationReuseIdentifierDirections = @"Directions";
NSString *const SFLocationReuseIdentifierTickets = @"Tickets";

@interface SFLocationViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSectionsForLocation:(Location *)location;

@end

@implementation SFLocationViewController

#pragma mark - NSObject

- (id)init
{
    self.collectionViewLayout = [[MSCollectionViewTableLayout alloc] init];
    self = [super initWithCollectionViewLayout:self.collectionViewLayout];
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(SELF == %@)", self.location];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    
    self.navigationItem.title = @"LOCATION";
    __weak typeof (self) weakSelf = self;
    self.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBackBarButtonItemWithSymbolsetTitle:@"\U00002B05" action:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self prepareSectionsForLocation:self.location];
}

#pragma mark - SFLocationViewController

- (void)prepareSectionsForLocation:(Location *)location
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    // Name Section
    {
        if (location.name && ![location.name isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFLocationTableSectionName,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFLocationReuseIdentifierName,
                    MSTableClass : MSGroupedTableViewCell.class,
                    MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                        cell.title.text = [weakSelf.location.name uppercaseString];
                    }
                 }]
             }];
        }
    }
    
    // Description Section
    {
        if (location.detail && ![location.detail isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFLocationTableSectionDescription,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFLocationReuseIdentifierDescription,
                    MSTableClass : MSMultlineGroupedTableViewCell.class,
                    MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                        cell.title.text = weakSelf.location.detail;
                        cell.selectionStyle = MSTableCellSelectionStyleNone;
                    },
                    MSTableSizeBlock : ^CGSize(CGFloat width){
                        return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:weakSelf.location.detail forWidth:width]);
                    }
                 }]
             }];
        }
    }
    
    // Location Section
    {
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFLocationTableSectionMap,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFLocationReuseIdentifierMap,
                    MSTableClass : SFMapCell.class,
                    MSTableConfigurationBlock : ^(SFMapCell *cell){
                        cell.region = MKCoordinateRegionMakeWithDistance(weakSelf.location.coordinate, 500.0, 500.0);
                    },
                    MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                        // Whoa whoa whoa holy hackfest
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            SFMapViewController *mapViewController = (SFMapViewController *)[(UINavigationController *)[[(SFAppDelegate *)[[UIApplication sharedApplication] delegate] navigationPaneViewController] paneViewController] childViewControllers][0];
                            [mapViewController.locationPopoverController dismissPopoverAnimated:YES];
                            [mapViewController.mapView setRegion:MKCoordinateRegionMakeWithDistance(weakSelf.location.coordinate, 500.0, 500.0) animated:YES];
                            [mapViewController popoverControllerDidDismissPopover:mapViewController.locationPopoverController];
                        } else {
                            [self dismissViewControllerAnimated:YES completion:^{
                                SFMapViewController *mapViewController = (SFMapViewController *)[(UINavigationController *)[[(SFAppDelegate *)[[UIApplication sharedApplication] delegate] navigationPaneViewController] paneViewController] childViewControllers][0];
                                [mapViewController.mapView setRegion:MKCoordinateRegionMakeWithDistance(weakSelf.location.coordinate, 500.0, 500.0) animated:YES];
                            }];
                        }
                    }
                 }]
             }];
        }
    }
    
    // Actions Section
    {        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFLocationReuseIdentifierTickets,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"PURCHASE TICKETS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
#warning implement
            }
        }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFLocationReuseIdentifierDirections,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"DIRECTIONS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                [weakSelf.location openInMapsWithRoute];
            }
        }];
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFLocationTableSectionActions,
            MSTableSectionRows : rows
        }];
    }
    
    
    self.collectionViewLayout.sections = sections;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeDelete:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case NSFetchedResultsChangeUpdate:
            [self prepareSectionsForLocation:self.location];
            break;
    }
}

@end

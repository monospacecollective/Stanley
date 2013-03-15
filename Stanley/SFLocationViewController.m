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
#import "SFHeroMapCell.h"
#import "Event.h"
#import "SFEventViewController.h"

// Sections
NSString *const SFLocationTableSectionName = @"Name";
NSString *const SFLocationTableSectionDescription = @"Description";
NSString *const SFLocationTableSectionEvents = @"Events";
NSString *const SFLocationTableSectionActions = @"Actions";

// Reuse Identifiers
NSString *const SFLocationReuseIdentifierHeader = @"Header";
NSString *const SFLocationReuseIdentifierName = @"Name";
NSString *const SFLocationReuseIdentifierDescription = @"Description";
NSString *const SFLocationReuseIdentifierEvent = @"Event";
NSString *const SFLocationReuseIdentifierDirections = @"Directions";

@interface SFLocationViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSections;

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
    
    self.navigationItem.title = @"LOCATION";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[SFStyleManager sharedManager] stylePopoverCollectionView:self.collectionView];
    } else {
        [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    }
    
    [self prepareSections];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - SFLocationViewController

- (void)prepareSections
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    // Name Section
    {
        if (self.location.name && ![self.location.name isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFLocationTableSectionName,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFLocationReuseIdentifierName,
                    MSTableClass : SFHeroMapCell.class,
                    MSTableConfigurationBlock : ^(SFHeroMapCell *cell){
                        cell.title.text = [weakSelf.location.name uppercaseString];
                        cell.region = MKCoordinateRegionMakeWithDistance(weakSelf.location.coordinate, 500.0, 500.0);
                    }
                 }]
             }];
        }
    }
    
    // Description Section
    {
        if (self.location.detail && ![self.location.detail isEqualToString:@""]) {
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
    
    // Actions Section
    {        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFLocationReuseIdentifierDirections,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"DIRECTIONS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                [weakSelf.location openInMapsWithRoute];
                [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }];
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFLocationTableSectionActions,
            MSTableSectionRows : rows
        }];
    }
    
    // Events
    {
        NSString *headerTitle = @"EVENTS";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFLocationReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        for (Event *event in self.location.sortedEvents) {
            
            [rows addObject:@{
                MSTableReuseIdentifer : SFLocationReuseIdentifierEvent,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = [event.name uppercaseString];
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath) {
                    SFEventViewController *eventViewController = [[SFEventViewController alloc] init];
                    eventViewController.event = event;
                    eventViewController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBackBarButtonItemWithAction:^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }];
                    [weakSelf.navigationController pushViewController:eventViewController animated:YES];
                }
            }];
        }
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFLocationTableSectionEvents,
                MSTableSectionHeader : header,
                MSTableSectionRows : rows
            }];
        }
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
            [self prepareSections];
            break;
    }
}

@end

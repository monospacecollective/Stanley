//
//  SFEventViewController.m
//  Stanley
//
//  Created by Eric Horacek on 3/9/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFEventViewController.h"
#import "SFStyleManager.h"
#import "Event.h"
#import "Film.h"
#import "Location.h"
#import "SFLocationViewController.h"
#import "SFHeroCell.h"
#import "SFWebViewController.h"

// Sections
NSString *const SFEventTableSectionName = @"Name";
NSString *const SFEventTableSectionTimes = @"Times";
NSString *const SFEventTableSectionLocation = @"Location";
NSString *const SFEventTableSectionDescription = @"Description";
NSString *const SFEventTableSectionFavorite = @"Favorite";
NSString *const SFEventTableSectionActions = @"Actions";

// Reuse Identifiers
NSString *const SFEventReuseIdentifierName = @"Name";
NSString *const SFEventReuseIdentifierFrom = @"From";
NSString *const SFEventReuseIdentifierTo = @"To";
NSString *const SFEventReuseIdentifierLocation = @"Location";
NSString *const SFEventReuseIdentifierDescription = @"Description";
NSString *const SFEventReuseIdentifierFavorite = @"Favorite";
NSString *const SFEventReuseIdentifierTickets = @"Tickets";

@interface SFEventViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSections;

@end

@implementation SFEventViewController

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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(SELF == %@)", self.event];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    self.navigationItem.title = (self.event.film ? @"SHOWING" : @"EVENT");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[SFStyleManager sharedManager] stylePopoverCollectionView:self.collectionView];
    } else {
        [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    }
    
    [self prepareSections];
}

#pragma mark - SFEventViewController

- (void)prepareSections
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    // Name
    {
        if (self.event.name && ![self.event.name isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFEventTableSectionName,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFEventReuseIdentifierName,
                    MSTableClass : SFHeroCell.class,
                    MSTableConfigurationBlock : ^(SFHeroCell *cell){
                        cell.title.text = [weakSelf.event.name uppercaseString];
                        [cell.backgroundImage setImageWithURL:[NSURL URLWithString:weakSelf.event.featureImage] placeholderImage:[[SFStyleManager sharedManager] heroPlaceholderImage]];
                    }
                 }]
             }];
        }
    }
    
    // Times
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEE, MMM d 'at' h:mm a";
        
        // From
        if (self.event.start) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFEventReuseIdentifierFrom,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"FROM";
                    cell.detail.text = [dateFormatter stringFromDate:weakSelf.event.start];
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
             }];
        }
        
        // To
        if (self.event.end) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFEventReuseIdentifierTo,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"TO";
                    cell.detail.text = [dateFormatter stringFromDate:weakSelf.event.end];
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
             }];
        }
    
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFEventTableSectionTimes,
                MSTableSectionRows : rows,
             }];
        }
    }
    
    // Location
    if (self.event.location) {
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFEventReuseIdentifierLocation,
            MSTableClass : MSRightDetailGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                cell.title.text = @"AT";
                cell.detail.text = weakSelf.event.location.name;
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                SFLocationViewController *locationController = [[SFLocationViewController alloc] init];
                [locationController setLocation:weakSelf.event.location];
                [weakSelf.navigationController pushViewController:locationController animated:YES];
                locationController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U00002B05" action:^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }
        }];
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFEventTableSectionActions,
                MSTableSectionRows : rows,
             }];
        }
    }
    
    // Description Section
    {
        if (self.event.detail && ![self.event.detail isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFEventTableSectionDescription,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFEventReuseIdentifierDescription,
                    MSTableClass : MSMultlineGroupedTableViewCell.class,
                    MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                        cell.title.text = weakSelf.event.detail;
                        cell.selectionStyle = MSTableCellSelectionStyleNone;
                    },
                    MSTableSizeBlock : ^CGSize(CGFloat width){
                        return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:weakSelf.event.detail forWidth:width]);
                    }
                 }]
             }];
        }
    }
    
    // Favorite Section
    {
        [sections addObject:@{
            MSTableSectionIdentifier : SFEventTableSectionFavorite,
            MSTableSectionRows : @[@{
                MSTableReuseIdentifer : SFEventReuseIdentifierFavorite,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"FAVORITE";
                    cell.accessoryType = [weakSelf.event.favorite boolValue] ? MSTableCellAccessoryStarFull : MSTableCellAccessoryStarEmpty;
                    if ([weakSelf.event.favorite boolValue]) {
                        [cell.groupedCellBackgroundView setFillColor:[UIColor colorWithHexString:@"5d0e0e"] forState:UIControlStateNormal];
                        [cell.groupedCellBackgroundView setBorderColor:[UIColor colorWithHexString:@"883939"] forState:UIControlStateNormal];
                        [cell.groupedCellBackgroundView setInnerShadowOffset:CGSizeMake(0.0, 0.0) forState:UIControlStateNormal];
                    } else {
                        [cell.groupedCellBackgroundView setFillColor:[MSGroupedCellBackgroundView.appearance fillColorForState:UIControlStateNormal] forState:UIControlStateNormal];
                        [cell.groupedCellBackgroundView setBorderColor:[MSGroupedCellBackgroundView.appearance borderColorForState:UIControlStateNormal] forState:UIControlStateNormal];
                    }
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                    weakSelf.event.favorite = @(![weakSelf.event.favorite boolValue]);
                    [weakSelf.event.managedObjectContext save:nil];
                    [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
             }]
         }];
    }
    
    // Actions
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        if (self.event.ticketURL) {
             [rows addObject:@{
                MSTableReuseIdentifer : SFEventReuseIdentifierTickets,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"PURCHASE TICKETS";
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                    SFWebViewController *webViewController = [[SFWebViewController alloc] init];
                    webViewController.requestURL = weakSelf.event.ticketURL;
                    webViewController.shouldScale = YES;
                    [weakSelf.navigationController pushViewController:webViewController animated:YES];
                }
            }];
        }
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFEventTableSectionActions,
                MSTableSectionRows : rows,
             }];
        }
    }
    
    self.collectionViewLayout.sections = sections;
}

@end

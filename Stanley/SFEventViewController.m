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
#import "SFWebViewController.h"

// Sections
NSString *const SFEventTableSectionName = @"Name";
NSString *const SFEventTableSectionTimes = @"Times";
NSString *const SFEventTableSectionLocation = @"Location";
NSString *const SFEventTableSectionDescription = @"Description";
NSString *const SFEventTableSectionActions = @"Actions";

// Reuse Identifiers
NSString *const SFEventReuseIdentifierName = @"Name";
NSString *const SFEventReuseIdentifierFrom = @"From";
NSString *const SFEventReuseIdentifierTo = @"To";
NSString *const SFEventReuseIdentifierDescription = @"Description";
NSString *const SFEventReuseIdentifierLocation = @"Location";
NSString *const SFEventReuseIdentifierTickets = @"Tickets";

@interface SFEventViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSectionsForEvent:(Event *)event;

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
    
    self.navigationItem.title = @"EVENT";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[SFStyleManager sharedManager] stylePopoverCollectionView:self.collectionView];
    } else {
        [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    }
    
    [self prepareSectionsForEvent:self.event];
}


#pragma mark - SFEventViewController

- (void)prepareSectionsForEvent:(Event *)event
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    // Name
    {
        if (event.name && ![event.name isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFEventTableSectionName,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFEventReuseIdentifierName,
                    MSTableClass : MSGroupedTableViewCell.class,
                    MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                        cell.title.text = [weakSelf.event.name uppercaseString];
                        cell.selectionStyle = MSTableCellSelectionStyleNone;
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
        if (event.start) {
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
        if (event.end) {
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
#warning check location existence
//    if (event.location) {
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFEventReuseIdentifierLocation,
            MSTableClass : MSRightDetailGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                cell.title.text = @"AT";
                cell.detail.text = @"Event Location";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
            
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
        if (event.detail && ![event.detail isEqualToString:@""]) {
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
                        return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:event.detail forWidth:width]);
                    }
                 }]
             }];
        }
    }
    
    // Actions
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFEventReuseIdentifierTickets,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"PURCHASE TICKETS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
            }
        }];
        
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
//
//  SFEventsViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/14/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFEventsViewController.h"
#import "SFStyleManager.h"
#import "SFCollectionViewStickyHeaderFlowLayout.h"
#import "Event.h"
#import "SFEventCell.h"
#import "SFCurrentTimeIndicatorCollectionReusableView.h"
#import "SFTimeRowHeaderCollectionReusableView.h"
#import "SFHorizontalGridlineCollectionReusableView.h"
#import "SFDayColumnHeaderCollectionReusableView.h"
#import "SFCurrentTimeHorizontalGridlineCollectionReusableView.h"
#import "SFHeaderBackgroundCollectionReusableView.h"
#import "SFEventViewController.h"
#import "SFPopoverNavigationBar.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"

NSString * const SFEventCellReuseIdentifier = @"SFEventCellReuseIdentifier";
NSString * const SFEventDayColumnHeaderReuseIdentifier = @"SFEventDayColumnHeaderReuseIdentifier";
NSString * const SFEventTimeRowHeaderReuseIdentifier = @"SFEventTimeRowHeaderReuseIdentifier";

@interface SFEventsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, MSCollectionViewDelegateCalendarLayout, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewLayout;
@property (nonatomic, strong) UIPopoverController *eventPopoverController;

- (void)reloadData;

@end

@implementation SFEventsViewController

- (id)init
{
    self.collectionViewLayout = [[MSCollectionViewCalendarLayout alloc] init];
    self.collectionViewLayout.delegate = self;
    self.collectionViewLayout.hourHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 100.0 : 80.0);
    self.collectionViewLayout.sectionWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 236.0 : 240.0);
    self.collectionViewLayout.timeRowHeaderWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 80.0 : 54.0);
    self.collectionViewLayout.dayColumnHeaderHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60.0 : 50.0);
    self.collectionViewLayout.currentTimeIndicatorSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGSizeMake(78.0, 40.0) : CGSizeMake(54.0, 40.0));
    self.collectionViewLayout.currentTimeHorizontalGridlineHeight = 8.0;
    self.collectionViewLayout.cellMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(1.0, 3.0, 1.0, 3.0) : UIEdgeInsetsMake(1.0, 3.0, 1.0, 3.0));
    self.collectionViewLayout.contentMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(30.0, 0.0, 30.0, 30.0) : UIEdgeInsetsMake(20.0, 0.0, 20.0, 10.0));
    self.collectionViewLayout.horizontalGridlineHeight = 2.0;
    self.collectionViewLayout.displayHeaderBackgroundAtOrigin = NO;
    
    self = [super initWithCollectionViewLayout:self.collectionViewLayout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SFStyleManager sharedManager] styleCollectionView:(UICollectionView *)self.collectionView];
    
    self.collectionView.alwaysBounceHorizontal = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView registerClass:SFEventCell.class forCellWithReuseIdentifier:SFEventCellReuseIdentifier];
    [self.collectionView registerClass:SFTimeRowHeaderCollectionReusableView.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:SFEventTimeRowHeaderReuseIdentifier];
    [self.collectionView registerClass:SFDayColumnHeaderCollectionReusableView.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [self.collectionViewLayout registerClass:SFCurrentTimeIndicatorCollectionReusableView.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
        [self.collectionViewLayout registerClass:SFHorizontalGridlineCollectionReusableView.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
        [self.collectionViewLayout registerClass:SFCurrentTimeHorizontalGridlineCollectionReusableView.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
        [self.collectionViewLayout registerClass:SFHeaderBackgroundCollectionReusableView.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
        [self.collectionViewLayout registerClass:SFHeaderBackgroundCollectionReusableView.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].persistentStoreManagedObjectContext
                                                                          sectionNameKeyPath:@"day"
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [self.navigationController setToolbarHidden:NO];
    __weak typeof(self) weakSelf = self;
    UIBarButtonItem *segmentedControlBarButtonItem = [[SFStyleManager sharedManager] styledBarSegmentedControlWithTitles:@[@"ALL EVENTS", @"FAVORITES"] action:^(NSUInteger newIndex) {
        if (newIndex == 1) {
            weakSelf.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(favorite == YES)"];
        } else {
            weakSelf.fetchedResultsController.fetchRequest.predicate = nil;
        }
        [weakSelf.fetchedResultsController performFetch:nil];
        [self.collectionView reloadData];
        [self.collectionViewLayout invalidateLayoutCache];
    }];
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], segmentedControlBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    
    [self reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionViewLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
    });
}

#pragma mark - SFEventsViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/events.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Event load failed with error: %@", error);
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
    [self.collectionViewLayout invalidateLayoutCache];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFEventCellReuseIdentifier forIndexPath:indexPath];
    cell.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return (UICollectionViewCell *)cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if ([kind isEqualToString:MSCollectionElementKindDayColumnHeader]) {
        
        NSDate *date = [self.collectionViewLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEEE, MMM d";
        SFDayColumnHeaderCollectionReusableView *dayColumnView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        dayColumnView.day.text = [[dateFormatter stringFromDate:date] uppercaseString];
        dayColumnView.today = [[date beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]];
        view = (UICollectionReusableView *)dayColumnView;
    }
    else if ([kind isEqualToString:MSCollectionElementKindTimeRowHeader]) {
        
        NSDate *date = [self.collectionViewLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"h a";
        
        SFTimeRowHeaderCollectionReusableView *timeRowView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFEventTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowView.time.text = [dateFormatter stringFromDate:date];
        view = (UICollectionReusableView *)timeRowView;
    }
    return view;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFEventViewController *eventController = [[SFEventViewController alloc] init];
    eventController.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFPopoverNavigationBar.class toolbarClass:SFToolbar.class];
        [navigationController addChildViewController:eventController];
        
        __weak typeof (self) weakSelf = self;
        eventController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U00002421" action:^{
            [weakSelf.eventPopoverController dismissPopoverAnimated:YES];
        }];
        
        self.eventPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        self.eventPopoverController.popoverBackgroundViewClass = GIKPopoverBackgroundView.class;
        self.eventPopoverController.delegate = self;
        [self.eventPopoverController presentPopoverFromRect:[self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame inView:self.collectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
        [navigationController addChildViewController:eventController];
        
        eventController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBackBarButtonItemWithSymbolsetTitle:@"\U00002B05" action:^{
            [eventController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - SFCollectionViewDelegateWeekLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout dayForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    if (sectionInfo.objects.count != 0) {
        Event *event = sectionInfo.objects[0];
        return [event.start beginningOfDay];
    } else {
        return nil;
    }
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.start;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.end;
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout
{
    return [NSDate date];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Required to get the popover to dealloc when it's removed
    self.eventPopoverController = nil;
}

@end

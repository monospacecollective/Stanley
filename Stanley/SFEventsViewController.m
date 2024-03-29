//
//  SFEventsViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/14/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFEventsViewController.h"
#import "SFStyleManager.h"
#import "SFEvent.h"
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
#import "SFNoContentBackgroundView.h"
#import "SFPopoverBackgroundView.h"

typedef NS_ENUM(NSUInteger, SFEventSegmentType) {
    SFEventSegmentTypeAll,
    SFEventSegmentTypeFavorites
};

NSString * const SFEventCellReuseIdentifier = @"SFEventCellReuseIdentifier";
NSString * const SFEventDayColumnHeaderReuseIdentifier = @"SFEventDayColumnHeaderReuseIdentifier";
NSString * const SFEventTimeRowHeaderReuseIdentifier = @"SFEventTimeRowHeaderReuseIdentifier";

@interface SFEventsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, MSCollectionViewDelegateCalendarLayout, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewLayout;
@property (nonatomic, strong) UIPopoverController *eventPopoverController;
@property (nonatomic, strong) SVSegmentedControl *favoriteSegmentedControl;

- (void)reloadData;
- (void)updateNoContentBackgroundForType:(SFEventSegmentType)type;

@end

@implementation SFEventsViewController

- (id)init
{
    self.collectionViewLayout = [[MSCollectionViewCalendarLayout alloc] init];
    self.collectionViewLayout.delegate = self;
    self.collectionViewLayout.hourHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 120.0 : 120.0);
    self.collectionViewLayout.sectionWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 300.0 : 250.0);
    self.collectionViewLayout.timeRowHeaderWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 80.0 : 44.0);
    self.collectionViewLayout.dayColumnHeaderHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60.0 : 40.0);
    self.collectionViewLayout.currentTimeIndicatorSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGSizeMake(78.0, 40.0) : CGSizeMake(44.0, 35.0));
    self.collectionViewLayout.currentTimeHorizontalGridlineHeight = 8.0;
    self.collectionViewLayout.cellMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(1.0, 3.0, 1.0, 3.0) : UIEdgeInsetsMake(1.0, 3.0, 1.0, 3.0));
    self.collectionViewLayout.contentMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(30.0, 0.0, 30.0, 30.0) : UIEdgeInsetsMake(20.0, 0.0, 20.0, 10.0));
    self.collectionViewLayout.sectionMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0) : UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0));
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

    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:SFEventCellReuseIdentifier];
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
    self.favoriteSegmentedControl = [[SFStyleManager sharedManager] styledSegmentedControlWithTitles:@[@"ALL EVENTS", @"FAVORITES"] action:^(NSUInteger newIndex) {
        
        if (newIndex == SFEventSegmentTypeAll) {
            weakSelf.fetchedResultsController.fetchRequest.predicate = nil;
        } else if (newIndex == SFEventSegmentTypeFavorites) {
            weakSelf.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(favorite == YES) OR (film.favorite == YES)"];
        }
        
        [weakSelf.fetchedResultsController performFetch:nil];
        
        [weakSelf updateNoContentBackgroundForType:newIndex];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionViewLayout invalidateLayoutCache];
        
        // Hacky
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.collectionViewLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
        });
    }];
    UIBarButtonItem *segmentedControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.favoriteSegmentedControl];
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], segmentedControlBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    
    [self updateNoContentBackgroundForType:self.favoriteSegmentedControl.selectedIndex];
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

- (void)updateNoContentBackgroundForType:(SFEventSegmentType)type
{
    BOOL shouldDisplayNoContentBackground = (self.fetchedResultsController.fetchedObjects.count == 0);
    
    if (shouldDisplayNoContentBackground) {
        
        SFNoContentBackgroundView *noContentBackgroundView;
        if (self.collectionView.backgroundView) {
            noContentBackgroundView = (SFNoContentBackgroundView *)self.collectionView.backgroundView;
        } else {
            noContentBackgroundView = [[SFNoContentBackgroundView alloc] init];
            self.collectionView.backgroundView = noContentBackgroundView;
        }
        
        switch (type) {
            case SFEventSegmentTypeFavorites:
                noContentBackgroundView.hidden = NO;
                noContentBackgroundView.title.text = @"NO FAVORITE EVENTS";
                noContentBackgroundView.icon.text = @"\U000022C6";
                noContentBackgroundView.subtitle.text = @"Keep track of your favorite events by marking them as favorites";
                break;
            case SFEventSegmentTypeAll:
                noContentBackgroundView.hidden = NO;
                noContentBackgroundView.title.text = @"NO EVENTS";
                noContentBackgroundView.icon.text = @"\U0001F4C6";
                noContentBackgroundView.subtitle.text = @"The events at the Stanley Film Fest are not yet announced. Check back later.";
                break;
        }
        
        [noContentBackgroundView setNeedsLayout];
        
    } else {
        self.collectionView.backgroundView.hidden = YES;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateNoContentBackgroundForType:self.favoriteSegmentedControl.selectedIndex];
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
//    cell.backgroundColor = [UIColor redColor];
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
        eventController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledCloseBarButtonItemWithAction:^{
            [weakSelf.eventPopoverController dismissPopoverAnimated:YES];
            weakSelf.eventPopoverController = nil;
        }];
        
        self.eventPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        self.eventPopoverController.popoverBackgroundViewClass = SFPopoverBackgroundView.class;
        self.eventPopoverController.delegate = self;
        [self.eventPopoverController presentPopoverFromRect:[self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame inView:self.collectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
        [navigationController addChildViewController:eventController];
        
        __weak typeof (self) weakSelf = self;
        eventController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledCloseBarButtonItemWithAction:^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - SFCollectionViewDelegateWeekLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout dayForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    if (sectionInfo.objects.count != 0) {
        SFEvent *event = sectionInfo.objects[0];
        return [event.start beginningOfDay];
    } else {
        return nil;
    }
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.start;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
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

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
#import "SFCollectionViewWeekLayout.h"
#import "Event.h"
#import "SFEventCollectionViewCell.h"
#import "SFCurrentTimeIndicatorCollectionReusableView.h"
#import "SFTimeRowHeaderCollectionReusableView.h"
#import "SFHorizontalGridlineCollectionReusableView.h"
#import "SFDayColumnHeaderCollectionReusableView.h"
#import "SFCurrentTimeHorizontalGridlineCollectionReusableView.h"
#import "SFHeaderBackgroundCollectionReusableView.h"

NSString * const SFEventCellReuseIdentifier = @"SFEventCollectionViewCellReuseIdentifier";
NSString * const SFEventDayColumnHeaderReuseIdentifier = @"SFEventDayColumnHeaderReuseIdentifier";
NSString * const SFEventTimeRowHeaderReuseIdentifier = @"SFEventTimeRowHeaderReuseIdentifier";

@interface SFEventsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, SFCollectionViewDelegateWeekLayout>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;

- (void)reloadData;

@end

@implementation SFEventsViewController

- (id)init
{
    self.objectChanges = [NSMutableArray new];
    self.sectionChanges = [NSMutableArray new];
    
    SFCollectionViewWeekLayout *layout = [[SFCollectionViewWeekLayout alloc] init];
    layout.delegate = self;
    layout.sectionLayoutType = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? SFWeekLayoutSectionLayoutTypeHorizontalTile : SFWeekLayoutSectionLayoutTypeVerticalTile);
    layout.hourHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 100.0 : 80.0);
    layout.sectionWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 236.0 : 256.0);
    layout.timeRowHeaderReferenceWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 80.0 : 54.0);
    layout.dayColumnHeaderReferenceHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60.0 : 50.0);
    layout.currentTimeIndicatorReferenceSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGSizeMake(78.0, 40.0) : CGSizeMake(54.0, 40.0));
    layout.sectionInset = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(1.0, 8.0, 1.0, 8.0) : UIEdgeInsetsMake(1.0, 8.0, 1.0, 8.0));
    layout.sectionMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(30.0, 0.0, 30.0, 30.0) : UIEdgeInsetsMake(20.0, 0.0, 20.0, 10.0));
    layout.horizontalGridlineReferenceHeight = 2.0;
    
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SFStyleManager sharedManager] styleCollectionView:(PSUICollectionView *)self.collectionView];
    [self.collectionView registerClass:SFEventCollectionViewCell.class forCellWithReuseIdentifier:SFEventCellReuseIdentifier];
    
    [self.collectionView registerClass:SFTimeRowHeaderCollectionReusableView.class forSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withReuseIdentifier:SFEventTimeRowHeaderReuseIdentifier];
    [self.collectionView registerClass:SFDayColumnHeaderCollectionReusableView.class forSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFCurrentTimeIndicatorCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFHorizontalGridlineCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindHorizontalGridline];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFCurrentTimeHorizontalGridlineCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindCurrentTimeHorizontalGridline];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFHeaderBackgroundCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindTimeRowHeaderBackground];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFHeaderBackgroundCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindDayColumnHeaderBackground];
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:@"day"
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:4] atScrollPosition:PSTCollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SFEventsViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/events.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@",[mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Event load failed with error: %@", error);
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.objectChanges removeAllObjects];
    [self.sectionChanges removeAllObjects];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([self.sectionChanges count] > 0) {
        [self.collectionView performBatchUpdates:^{
            for (NSDictionary *change in self.sectionChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id object, BOOL *stop) {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type) {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[object unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[object unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[object unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0) {
        if ([self shouldReloadCollectionViewToPreventKnownIssue]) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
        } else {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary *change in self.objectChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id object, BOOL *stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[object]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[object]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[object]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:object[0] toIndexPath:object[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = object;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    return shouldReload;
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

- (PSUICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFEventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFEventCellReuseIdentifier forIndexPath:indexPath];
    cell.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return (PSUICollectionViewCell *)cell;
}

- (PSUICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PSUICollectionReusableView *view;
    if ([kind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
        
        NSDate *date = [(SFCollectionViewWeekLayout *)self.collectionView.collectionViewLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEEE, MMM d";
        SFDayColumnHeaderCollectionReusableView *dayColumnView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        dayColumnView.day.text = [[dateFormatter stringFromDate:date] uppercaseString];
        dayColumnView.today = [[date beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]];
        view = (PSUICollectionReusableView *)dayColumnView;
    }
    else if ([kind isEqualToString:SFCollectionElementKindTimeRowHeader]) {
        
        NSDate *date = [(SFCollectionViewWeekLayout *)self.collectionView.collectionViewLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"h a";
        
        SFTimeRowHeaderCollectionReusableView *timeRowView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFEventTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowView.time.text = [dateFormatter stringFromDate:date];
        view = (PSUICollectionReusableView *)timeRowView;
    }
    return view;
}

#pragma mark - SFCollectionViewDelegateWeekLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout dayForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    if (sectionInfo.objects.count != 0) {
        Event *event = sectionInfo.objects[0];
        return [event.start beginningOfDay];
    } else {
        return nil;
    }
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.start;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.end;
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout
{
    return [NSDate date];
}

@end

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
#import "SFCurrentTimeIndicatorCollectionViewCell.h"
#import "Event.h"
#import "SFTimeRowHeaderCollectionReusableView.h"
#import "SFDayColumnHeaderCollectionReusableView.h"
#import "SFEventCollectionViewCell.h"

NSString * const SFEventCellReuseIdentifier = @"SFEventCollectionViewCellReuseIdentifier";
NSString * const SFEventDayColumnHeaderReuseIdentifier = @"SFEventDayColumnHeaderReuseIdentifier";
NSString * const SFEventTimeRowHeaderReuseIdentifier = @"SFEventTimeRowHeaderReuseIdentifier";
NSString * const SFEventCurrentTimeIndicatorReuseIdentifier = @"SFEventCurrentTimeIndicatorReuseIdentifier";

@interface SFEventsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, SFCollectionViewDelegateWeekLayout>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)reloadData;

@end

@implementation SFEventsViewController

- (id)init
{
    id layout;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        layout = [[SFCollectionViewWeekLayout alloc] init];
        [layout setDelegate:self];
    } else {
        layout = [[SFCollectionViewStickyHeaderFlowLayout alloc] init];
    }
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [[SFStyleManager sharedManager] styleCollectionView:(PSUICollectionView *)self.collectionView];
    [self.collectionView registerClass:SFEventCollectionViewCell.class forCellWithReuseIdentifier:SFEventCellReuseIdentifier];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.collectionView registerClass:SFTimeRowHeaderCollectionReusableView.class forSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withReuseIdentifier:SFEventTimeRowHeaderReuseIdentifier];
        [self.collectionView registerClass:SFDayColumnHeaderCollectionReusableView.class forSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFCurrentTimeIndicatorCollectionViewCell.class forDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator];
    } else {
        [self.collectionView registerClass:PSUICollectionReusableView.class forSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier];
    }
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        
    } else {
        
        PSUICollectionViewFlowLayout *flowLayout = (PSUICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        
        flowLayout.itemSize = CGSizeMake(320.0, 88.0);
        flowLayout.headerReferenceSize = CGSizeMake(320.0, 44.0);
        
        CGFloat spacingSize = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(spacingSize, spacingSize, spacingSize, spacingSize);
        flowLayout.minimumLineSpacing = spacingSize;

    }
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
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
    return cell;
}

- (PSUICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PSUICollectionReusableView *view;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([kind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
            
            NSDate *date = [(SFCollectionViewWeekLayout *)self.collectionView.collectionViewLayout dateForDayColumnHeaderAtIndexPath:indexPath];
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"EEEE, MMM d";
            SFDayColumnHeaderCollectionReusableView *dayColumnView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
            dayColumnView.day.text = [[dateFormatter stringFromDate:date] uppercaseString];
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
    } else {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        view.backgroundColor = [UIColor blueColor];
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

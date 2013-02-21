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

- (void)reloadData;

@end

@implementation SFEventsViewController

- (id)init
{
    SFCollectionViewWeekLayout *layout = [[SFCollectionViewWeekLayout alloc] init];
    layout.delegate = self;
    
    layout.sectionLayoutType = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? SFWeekLayoutSectionLayoutTypeHorizontalTile : SFWeekLayoutSectionLayoutTypeVerticalTile);
    layout.hourHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70.0 : 60.0);
    layout.sectionWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 236.0 : 266.0);
    layout.timeRowHeaderReferenceWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 80.0 : 54.0);
    layout.dayColumnHeaderReferenceHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60.0 : 60.0);
    layout.currentTimeIndicatorReferenceSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGSizeMake(80.0, 40.0) : CGSizeMake(54.0, 40.0));
    layout.sectionInset = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0) : UIEdgeInsetsMake(8.0, 12.0, 8.0, 12.0));
    layout.sectionMargin = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(30.0, 0.0, 60.0, 0.0) : UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0));
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
    
    [self.collectionView registerClass:SFTimeRowHeaderCollectionReusableView.class forSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withReuseIdentifier:SFEventTimeRowHeaderReuseIdentifier];
    [self.collectionView registerClass:SFDayColumnHeaderCollectionReusableView.class forSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withReuseIdentifier:SFEventDayColumnHeaderReuseIdentifier];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFCurrentTimeIndicatorCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFHorizontalGridlineCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindHorizontalGridline];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFCurrentTimeHorizontalGridlineCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindCurrentTimeHorizontalGridline];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFHeaderBackgroundCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindTimeRowHeaderBackground];
        [(UICollectionViewLayout *)self.collectionView.collectionViewLayout registerClass:SFHeaderBackgroundCollectionReusableView.class forDecorationViewOfKind:SFCollectionElementKindDayColumnHeaderBackground];
    }
    
    [self reloadData];
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

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

NSString * const SFEventCollectionViewCellReuseIdentifier = @"SFEventCollectionViewCellReuseIdentifier";
NSString * const SFEventDayHeaderCollectionReusableViewReuseIdentifier = @"SFEventDayHeaderCollectionReusableViewReuseIdentifier";

@interface SFEventsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)reloadData;

@end

@implementation SFEventsViewController

- (id)init
{
    id layout;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        layout = [[SFCollectionViewStickyHeaderFlowLayout alloc] init];
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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:@"day"
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [[SFStyleManager sharedManager] styleCollectionView:(PSUICollectionView *)self.collectionView];
    [self.collectionView registerClass:PSUICollectionViewCell.class forCellWithReuseIdentifier:SFEventCollectionViewCellReuseIdentifier];
    [self.collectionView registerClass:PSUICollectionReusableView.class forSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withReuseIdentifier:SFEventDayHeaderCollectionReusableViewReuseIdentifier];
    
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
    PSUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFEventCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    cell.layer.borderColor = [[UIColor greenColor] CGColor];
    cell.layer.borderWidth = 1.0;
    return cell;
}

- (PSUICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PSUICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withReuseIdentifier:SFEventDayHeaderCollectionReusableViewReuseIdentifier forIndexPath:indexPath];
    view.backgroundColor = [UIColor blueColor];
    view.layer.borderColor = [[UIColor purpleColor] CGColor];
    view.layer.borderWidth = 1.0;
    return view;
}

@end

//
//  SFFilmsViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFFilmsViewController.h"
#import "Film.h"
#import "SFFilmCell.h"
#import "SFStyleManager.h"
#import "SFFilmViewController.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"

NSString * const SFFilmCellReuseIdentifier = @"SFFilmCellReuseIdentifier";

@interface SFFilmsViewController () <NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIPopoverController *filmPopoverController;

- (void)reloadData;

@end

@implementation SFFilmsViewController

- (id)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Film"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [self.navigationController setToolbarHidden:NO];
    
    __weak typeof(self) weakSelf = self;
    UIBarButtonItem *segmentedControlBarButtonItem = [[SFStyleManager sharedManager] styledBarSegmentedControlWithTitles:@[@"ALL FILMS", @"FAVORITES"] action:^(NSUInteger newIndex) {
        
        if (newIndex == 1) {
            weakSelf.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(favorite == YES)"];
        } else {
            weakSelf.fetchedResultsController.fetchRequest.predicate = nil;
        }
        
        NSSet *previousObjects = [NSSet setWithArray:weakSelf.fetchedResultsController.fetchedObjects];
        NSMutableDictionary *previousObjectIndexPaths = [NSMutableDictionary new];
        for (Film *film in previousObjects) {
            NSIndexPath *indexPath = [weakSelf.fetchedResultsController indexPathForObject:film];
            previousObjectIndexPaths[indexPath] = film;
        }
        
        [weakSelf.fetchedResultsController performFetch:nil];
        
        NSSet *newObjects = [NSSet setWithArray:weakSelf.fetchedResultsController.fetchedObjects];
        NSMutableDictionary *newObjectIndexPaths = [NSMutableDictionary new];
        for (Film *film in newObjects) {
            NSIndexPath *indexPath = [weakSelf.fetchedResultsController indexPathForObject:film];
            newObjectIndexPaths[indexPath] = film;
        }
        
        NSMutableSet *insertions = [newObjects mutableCopy];
        [insertions minusSet:previousObjects];
        
        NSMutableSet *deletions = [previousObjects mutableCopy];
        [deletions minusSet:newObjects];
        
        NSMutableArray *insertedIndexPaths = [NSMutableArray new];
        for (Film *film in insertions) {
            [insertedIndexPaths addObjectsFromArray:[newObjectIndexPaths allKeysForObject:film]];
        }
        
        NSMutableArray *deletedIndexPaths = [NSMutableArray new];
        for (Film *film in deletions) {
            [deletedIndexPaths addObjectsFromArray:[previousObjectIndexPaths allKeysForObject:film]];
        }
        
        [weakSelf.collectionView performBatchUpdates:^{
            [weakSelf.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
            [weakSelf.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];
        } completion:nil];
    }];
    
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], segmentedControlBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    
    
    self.collectionView.alwaysBounceVertical = YES;
    [[SFStyleManager sharedManager] styleCollectionView:(UICollectionView *)self.collectionView];
    
    [self.collectionView registerClass:SFFilmCell.class forCellWithReuseIdentifier:SFFilmCellReuseIdentifier];
    
    [self reloadData];
}

- (void)viewWillLayoutSubviews
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = [SFFilmCell cellSizeForInterfaceOrientation:self.interfaceOrientation];
    flowLayout.sectionInset = [SFFilmCell cellMarginForInterfaceOrientation:self.interfaceOrientation];
    flowLayout.minimumLineSpacing = [SFFilmCell cellSpacingForInterfaceOrientation:self.interfaceOrientation];;
}

#pragma mark - SFFilmsViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/films.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Film load failed with error: %@", error);
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFFilmCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFFilmCellReuseIdentifier forIndexPath:indexPath];
    cell.film = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFFilmViewController *filmController = [[SFFilmViewController alloc] init];
    filmController.film = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.filmPopoverController = [[UIPopoverController alloc] initWithContentViewController:filmController];
        self.filmPopoverController.popoverBackgroundViewClass = GIKPopoverBackgroundView.class;
        self.filmPopoverController.delegate = self;
        [self.filmPopoverController presentPopoverFromRect:[self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame inView:self.collectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
        [navigationController addChildViewController:filmController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Required to get the popover to dealloc when it's removed
    self.filmPopoverController = nil;
}

@end

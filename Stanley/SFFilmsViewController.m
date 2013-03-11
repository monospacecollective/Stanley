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
#import "SFPopoverNavigationBar.h"
#import "SFPopoverToolbar.h"
#import "SFNoContentBackgroundView.h"

typedef NS_ENUM(NSUInteger, SFFilmSegmentType) {
    SFFilmSegmentTypeAll,
    SFFilmSegmentTypeFavorites
};

NSString * const SFFilmCellReuseIdentifier = @"SFFilmCellReuseIdentifier";

@interface SFFilmsViewController () <NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIPopoverController *filmPopoverController;
@property (nonatomic, strong) SVSegmentedControl *favoriteSegmentedControl;

- (void)reloadData;
- (void)updateNoContentBackgroundForType:(SFFilmSegmentType)type;

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
    
    self.favoriteSegmentedControl = [[SFStyleManager sharedManager] styledSegmentedControlWithTitles:@[@"ALL FILMS", @"FAVORITES"] action:^(NSUInteger newIndex) {
        
        if (newIndex == SFFilmSegmentTypeFavorites) {
            weakSelf.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(favorite == YES)"];
        } else if (newIndex == SFFilmSegmentTypeAll) {
            weakSelf.fetchedResultsController.fetchRequest.predicate = nil;
        }
        
        NSSet *previousObjects = [NSSet setWithArray:weakSelf.fetchedResultsController.fetchedObjects];
        NSMutableDictionary *previousObjectIndexPaths = [NSMutableDictionary new];
        for (Film *film in previousObjects) {
            NSIndexPath *indexPath = [weakSelf.fetchedResultsController indexPathForObject:film];
            previousObjectIndexPaths[indexPath] = film;
        }
        
        [weakSelf.fetchedResultsController performFetch:nil];
        [self updateNoContentBackgroundForType:newIndex];
        
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
    UIBarButtonItem *segmentedControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.favoriteSegmentedControl];
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], segmentedControlBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    
    self.collectionView.alwaysBounceVertical = YES;
    [[SFStyleManager sharedManager] styleCollectionView:(UICollectionView *)self.collectionView];
    
    [self.collectionView registerClass:SFFilmCell.class forCellWithReuseIdentifier:SFFilmCellReuseIdentifier];
    
    [self updateNoContentBackgroundForType:self.favoriteSegmentedControl.selectedIndex];
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

- (void)updateNoContentBackgroundForType:(SFFilmSegmentType)type
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
            case SFFilmSegmentTypeFavorites:
                noContentBackgroundView.hidden = NO;
                noContentBackgroundView.title.text = @"NO FAVORITE FILMS";
                noContentBackgroundView.icon.text = @"\U000022C6";
                noContentBackgroundView.subtitle.text = @"Keep track of your favorite films by marking them as favorites";
                break;
            case SFFilmSegmentTypeAll:
                noContentBackgroundView.hidden = NO;
                noContentBackgroundView.title.text = @"NO FILMS";
                noContentBackgroundView.icon.text = @"\U0000E320";
                noContentBackgroundView.subtitle.text = @"The films showing at the Stanley Film Fest are not yet announced. Check back later.";
                break;
        }
        
    } else {
        self.collectionView.backgroundView.hidden = YES;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateNoContentBackgroundForType:self.favoriteSegmentedControl.selectedIndex];
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
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFPopoverNavigationBar.class toolbarClass:SFPopoverToolbar.class];
        [navigationController addChildViewController:filmController];
        
        __weak typeof (self) weakSelf = self;
        filmController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U00002421" action:^{
            [weakSelf.filmPopoverController dismissPopoverAnimated:YES];
        }];
        
        self.filmPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        self.filmPopoverController.popoverBackgroundViewClass = GIKPopoverBackgroundView.class;
        self.filmPopoverController.delegate = self;
        [self.filmPopoverController presentPopoverFromRect:[self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame inView:self.collectionView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
        [navigationController addChildViewController:filmController];
        
        filmController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBackBarButtonItemWithSymbolsetTitle:@"\U00002B05" action:^{
            [filmController dismissViewControllerAnimated:YES completion:nil];
        }];
        
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

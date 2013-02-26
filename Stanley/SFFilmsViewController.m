//
//  SFFilmsViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFFilmsViewController.h"
#import "Film.h"
#import "SFFilmCollectionViewCell.h"
#import "SFStyleManager.h"

NSString * const SFFilmCollectionViewCellReuseIdentifier = @"SFFilmCollectionViewCellReuseIdentifier";

@interface SFFilmsViewController () <PSUICollectionViewDataSource, PSUICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)reloadData;

@end

@implementation SFFilmsViewController

- (id)init
{
    PSUICollectionViewFlowLayout *layout = [[PSUICollectionViewFlowLayout alloc] init];
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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [[SFStyleManager sharedManager] styleCollectionView:(PSUICollectionView *)self.collectionView];
    [self.collectionView registerClass:SFFilmCollectionViewCell.class forCellWithReuseIdentifier:SFFilmCollectionViewCellReuseIdentifier];
    
    [self reloadData];
}

- (void)viewWillLayoutSubviews
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = [SFFilmCollectionViewCell cellSizeForInterfaceOrientation:self.interfaceOrientation];
    flowLayout.sectionInset = [SFFilmCollectionViewCell cellMarginForInterfaceOrientation:self.interfaceOrientation];
    flowLayout.minimumLineSpacing = [SFFilmCollectionViewCell cellSpacingForInterfaceOrientation:self.interfaceOrientation];;
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

- (PSUICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFFilmCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFFilmCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.film = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

@end

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
    
    [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Film"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    
    [self.collectionView registerClass:SFFilmCollectionViewCell.class forCellWithReuseIdentifier:SFFilmCollectionViewCellReuseIdentifier];
    
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert(fetchSuccessful, @"Unable to fetch films");
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    flowLayout.itemSize = [SFFilmCollectionViewCell cellSize];
    
    CGFloat spacingSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        spacingSize = 10.0;
    } else {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            spacingSize = 23.0;
        } else {
            spacingSize = 49.0;
        }
    }
    flowLayout.sectionInset = UIEdgeInsetsMake(spacingSize, spacingSize, spacingSize, spacingSize);
    flowLayout.minimumLineSpacing = spacingSize;
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
    SFFilmCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SFFilmCollectionViewCellReuseIdentifier forIndexPath:indexPath];
    cell.film = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}

@end

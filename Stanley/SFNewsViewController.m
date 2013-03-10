//
//  SFNewsViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/15/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFNewsViewController.h"
#import "Announcement.h"
#import "SFAnnouncementCell.h"
#import "SFStyleManager.h"
#import "SFCollectionViewStickyHeaderFlowLayout.h"

NSString * const SFNewsTableViewCellReuseIdentifier = @"SFNewsTableViewCellReuseIdentifier";
NSString * const SFHeaderReuseIdentifier = @"SFHeaderReuseIdentifier";

@interface SFNewsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) SFCollectionViewStickyHeaderFlowLayout *collectionViewLayout;

- (void)reloadData;

@end

@implementation SFNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.collectionViewLayout = [[SFCollectionViewStickyHeaderFlowLayout alloc] init];
    self.collectionViewLayout.minimumLineSpacing = 0.0;
    self.collectionViewLayout.stickySectionHeaders = YES;
    self.collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    self = [super initWithCollectionViewLayout:self.collectionViewLayout];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    self.collectionView.alwaysBounceVertical = YES;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Announcement"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(published != nil)"];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:@"dayPublished"
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [self.collectionView registerClass:SFAnnouncementCell.class forCellWithReuseIdentifier:SFNewsTableViewCellReuseIdentifier];
    [self.collectionView registerClass:MSPlainTableViewHeaderView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SFHeaderReuseIdentifier];
    
    [self reloadData];
}

#pragma mark - SFFilmsViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/announcements.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Announcement load failed with error: %@", error);
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}

#pragma mark - UITableViewDataSource

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
    SFAnnouncementCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:SFNewsTableViewCellReuseIdentifier forIndexPath:indexPath];
    Announcement *announcement = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.announcement = announcement;
    return cell;
}

- (NSString *)collectionView:(UICollectionView *)collectionView titleForSupplementaryElementOfKind:(NSString *)kind inSection:(NSInteger)section
{
    if (kind == UICollectionElementKindSectionHeader) {   
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
        NSString *title;
        if (sectionInfo.objects.count != 0) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"EEEE, MMM d";
            Announcement *announcement = sectionInfo.objects[0];
            title = [dateFormatter stringFromDate:[announcement.published beginningOfDay]];
        }
        return [title uppercaseString];
    }
    return nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        MSPlainTableViewHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SFHeaderReuseIdentifier forIndexPath:indexPath];
        headerView.title.text = [self collectionView:collectionView titleForSupplementaryElementOfKind:kind inSection:indexPath.section];
        return headerView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    CGFloat height = [SFAnnouncementCell height];
    return CGSizeMake(width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    CGFloat height = 28.0;
    return CGSizeMake(width, height);
}

@end

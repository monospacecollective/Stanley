//
//  SFFilmViewController.m
//  Stanley
//
//  Created by Eric Horacek on 3/6/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFFilmViewController.h"
#import "SFHeroCell.h"
#import "SFStyleManager.h"
#import "Film.h"
#import "SFWebViewController.h"

// Sections
NSString *const SFFilmViewControllerTableSectionTitle = @"Title";
NSString *const SFFilmViewControllerTableSectionDescription = @"Description";
NSString *const SFFilmViewControllerTableSectionInfo = @"Info";
NSString *const SFFilmViewControllerTableSectionPeople = @"People";
NSString *const SFFilmViewControllerTableSectionFavorite = @"Favorite";
NSString *const SFFilmViewControllerTableSectionActions = @"Actions";

// Reuse Identifiers
// Title
NSString *const SFFilmReuseIdentifierTitle = @"Title";
// Favorite
NSString *const SFFilmReuseIdentifierFavorite = @"Favorite";
// Description
NSString *const SFFilmReuseIdentifierDescription = @"Description";
// People
NSString *const SFFilmReuseIdentifierDirectors = @"Directors";
NSString *const SFFilmReuseIdentifierStars = @"Stars";
NSString *const SFFilmReuseIdentifierProducers = @"Producers";
NSString *const SFFilmReuseIdentifierWriters = @"Writers";
// Info
NSString *const SFFilmReuseIdentifierCountry = @"Country";
NSString *const SFFilmReuseIdentifierYear = @"Year";
NSString *const SFFilmReuseIdentifierLanguage = @"Language";
NSString *const SFFilmReuseIdentifierRuntime = @"Runtime";
NSString *const SFFilmReuseIdentifierRating = @"Rating";
NSString *const SFFilmReuseIdentifierPrintSource = @"PrintSource";
NSString *const SFFilmReuseIdentifierFilmography = @"Filmography";
// Actions
NSString *const SFFilmReuseIdentifierTickets = @"Tickets";

@interface SFFilmViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSectionsForFilm:(Film *)film;

@end

@implementation SFFilmViewController

#pragma mark - NSObject

- (id)init
{
    self.collectionViewLayout = [[MSCollectionViewTableLayout alloc] init];
    self = [super initWithCollectionViewLayout:self.collectionViewLayout];
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Film"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(SELF == %@)", self.film];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    self.navigationItem.title = @"FILM";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[SFStyleManager sharedManager] stylePopoverCollectionView:self.collectionView];
    } else {
        [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    }
    
    [self prepareSectionsForFilm:self.film];
}

#pragma mark - SFFilmViewController

- (void)prepareSectionsForFilm:(Film *)film
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    // Name Section
    {
        if (film.name && ![film.name isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFFilmViewControllerTableSectionTitle,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFFilmReuseIdentifierTitle,
                    MSTableClass : SFHeroCell.class,
                    MSTableConfigurationBlock : ^(SFHeroCell *cell){
                        cell.title.text = [weakSelf.film.name uppercaseString];
                        [cell.backgroundImage setImageWithURL:[NSURL URLWithString:film.featureImage]];
                    }
                 }]
             }];
        }
    }
    
    // Description Section
    {
        if (film.detail && ![film.detail isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFFilmViewControllerTableSectionDescription,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFFilmReuseIdentifierDescription,
                    MSTableClass : MSMultlineGroupedTableViewCell.class,
                    MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                        cell.title.text = weakSelf.film.detail;
                        cell.selectionStyle = MSTableCellSelectionStyleNone;
                    },
                    MSTableSizeBlock : ^CGSize(CGFloat width){
                        return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:weakSelf.film.detail forWidth:width]);
                    }
                 }]
             }];
        }
    }
    
    // Info Section
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        // Language
        if (film.language && ![film.language isEqualToString:@""]) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierLanguage,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"LANGUAGE";
                    cell.detail.text = weakSelf.film.language;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
             }];
        }
        
        // Runtime
        if (film.runtime) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierRuntime,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"RUNTIME";
                    cell.detail.text = [weakSelf.film runtimeString];
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
             }];
        }
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFFilmViewControllerTableSectionInfo,
                MSTableSectionRows : rows,
             }];
        }
    }
    
    // People Section
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        // Directors
        if (film.directors.count) {
            NSString *title = [weakSelf.film directorsTitleString];
            NSString *detail = [weakSelf.film directorsListSeparatedByString:@"\n"];
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierDirectors,
                MSTableClass : MSMultilineRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultilineRightDetailGroupedTableViewCell *cell){
                    cell.title.text = title;
                    cell.detail.text = detail;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultilineRightDetailGroupedTableViewCell heightForTitle:title detail:detail forWidth:width]);
                }
             }];
        }
        
        // Writers
        if (film.writers.count) {
            NSString *title = [weakSelf.film writersTitleString];
            NSString *detail = [weakSelf.film writersListSeparatedByString:@"\n"];
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierWriters,
                MSTableClass : MSMultilineRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultilineRightDetailGroupedTableViewCell *cell){
                    cell.title.text = title;
                    cell.detail.text = detail;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultilineRightDetailGroupedTableViewCell heightForTitle:title detail:detail forWidth:width]);
                }
             }];
        }
        
        // Producers
        if (film.producers.count) {
            NSString *title = [weakSelf.film producersTitleString];
            NSString *detail = [weakSelf.film producersListSeparatedByString:@"\n"];
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierProducers,
                MSTableClass : MSMultilineRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultilineRightDetailGroupedTableViewCell *cell){
                    cell.title.text = title;
                    cell.detail.text = detail;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultilineRightDetailGroupedTableViewCell heightForTitle:title detail:detail forWidth:width]);
                }
             }];
        }
        
        // Stars
        if (film.stars.count) {
            NSString *title = [weakSelf.film starsTitleString];
            NSString *detail = [weakSelf.film starsListSeparatedByString:@"\n"];
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierStars,
                MSTableClass : MSMultilineRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultilineRightDetailGroupedTableViewCell *cell){
                    cell.title.text = title;
                    cell.detail.text = detail;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    CGFloat height = [MSMultilineRightDetailGroupedTableViewCell heightForTitle:title detail:detail forWidth:width];
                    return CGSizeMake(width, height);
                }
             }];
        }
        
        if (rows.count) {
            [sections addObject:@{
                 MSTableSectionIdentifier : SFFilmViewControllerTableSectionPeople,
                 MSTableSectionRows : rows
             }];
        }
    }
    
    // Favorite Section
    {
        [sections addObject:@{
            MSTableSectionIdentifier : SFFilmViewControllerTableSectionFavorite,
            MSTableSectionRows : @[@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierFavorite,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"FAVORITE";
                    cell.accessoryType = [weakSelf.film.favorite boolValue] ? MSTableCellAccessoryStarFull : MSTableCellAccessoryStarEmpty;
                    if ([weakSelf.film.favorite boolValue]) {
                        [cell.groupedCellBackgroundView setFillColor:[UIColor colorWithHexString:@"5d0e0e"] forState:UIControlStateNormal];
                        [cell.groupedCellBackgroundView setBorderColor:[UIColor colorWithHexString:@"883939"] forState:UIControlStateNormal];
                        [cell.groupedCellBackgroundView setInnerShadowOffset:CGSizeMake(0.0, 0.0) forState:UIControlStateNormal];
                    } else {
                        [cell.groupedCellBackgroundView setFillColor:[MSGroupedCellBackgroundView.appearance fillColorForState:UIControlStateNormal] forState:UIControlStateNormal];
                        [cell.groupedCellBackgroundView setBorderColor:[MSGroupedCellBackgroundView.appearance borderColorForState:UIControlStateNormal] forState:UIControlStateNormal];
                    }
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                    weakSelf.film.favorite = @(![weakSelf.film.favorite boolValue]);
                    [weakSelf.film.managedObjectContext save:nil];
                    [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
             }]
         }];
    }
    
    // Actions Section
    {
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFFilmReuseIdentifierTickets,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"PURCHASE TICKETS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath) {
                SFWebViewController *webViewController = [[SFWebViewController alloc] init];
                webViewController.requestURL = @"http://www.stanleyhotel.com";
                webViewController.shouldScale = YES;
                [weakSelf.navigationController pushViewController:webViewController animated:YES];
            }
         }];
        
        if (rows.count) {
            [sections addObject:@{
                 MSTableSectionIdentifier : SFFilmViewControllerTableSectionActions,
                 MSTableSectionRows : rows
             }];
        }
    }
    
    for (NSDictionary *section in sections) {
        for (NSDictionary *row in section[MSTableSectionRows]) {
            [self.collectionView registerClass:row[MSTableClass] forCellWithReuseIdentifier:row[MSTableReuseIdentifer]];
        }
    }
    
    self.collectionViewLayout.sections = sections;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeDelete:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case NSFetchedResultsChangeUpdate:
            [self prepareSectionsForFilm:self.film];
            break;
    }
}

@end

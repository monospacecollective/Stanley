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
#import "Event.h"
#import "SFWebViewController.h"
#import "SFEventViewController.h"

// Sections
NSString *const SFFilmViewControllerTableSectionTitle = @"Title";
NSString *const SFFilmViewControllerTableSectionDescription = @"Description";
NSString *const SFFilmViewControllerTableSectionInfo = @"Info";
NSString *const SFFilmViewControllerTableSectionPeople = @"People";
NSString *const SFFilmViewControllerTableSectionFavorite = @"Favorite";
NSString *const SFFilmViewControllerTableSectionShowings = @"Showings";
NSString *const SFFilmViewControllerTableSectionActions = @"Actions";

// Reuse Identifiers
// Headers
NSString *const SFFilmReuseIdentifierHeader = @"Header";
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
// Showings
NSString *const SFFilmReuseIdentifierShowing = @"Showing";
// Actions
NSString *const SFFilmReuseIdentifierTickets = @"Tickets";

@interface SFFilmViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSections;

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
    
    [self prepareSections];
}

#pragma mark - SFFilmViewController

- (void)prepareSections
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    // Name Section
    {
        if (self.film.name && ![self.film.name isEqualToString:@""]) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFFilmViewControllerTableSectionTitle,
                MSTableSectionRows : @[@{
                    MSTableReuseIdentifer : SFFilmReuseIdentifierTitle,
                    MSTableClass : SFHeroCell.class,
                    MSTableConfigurationBlock : ^(SFHeroCell *cell){
                        cell.title.text = [weakSelf.film.name uppercaseString];
                        [cell.backgroundImage setImageWithURL:[NSURL URLWithString:weakSelf.film.featureImage] placeholderImage:[[SFStyleManager sharedManager] heroPlaceholderImage]];
                    }
                 }]
             }];
        }
    }
    
    // Description Section
    {
        if (self.film.detail && ![self.film.detail isEqualToString:@""]) {
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
        
        if (self.film.ticketURL && ![self.film.ticketURL isEqualToString:@""]) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierTickets,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"PURCHASE TICKETS";
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath) {
                    SFWebViewController *webViewController = [[SFWebViewController alloc] init];
                    webViewController.requestURL = weakSelf.film.ticketURL;
                    webViewController.shouldScale = YES;
                    [weakSelf.navigationController pushViewController:webViewController animated:YES];
                }
            }];
        }
        
        if (rows.count) {
            [sections addObject:@{
                 MSTableSectionIdentifier : SFFilmViewControllerTableSectionActions,
                 MSTableSectionRows : rows
             }];
        }
    }
    
    // Showings
    {
        NSString *headerTitle = @"SHOWINGS";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFFilmReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        for (Event *showing in self.film.sortedShowings) {
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"EEE, MMM d 'at' h:mm a";
            
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierShowing,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = [[dateFormatter stringFromDate:showing.start] uppercaseString];
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath) {
                    SFEventViewController *eventViewController = [[SFEventViewController alloc] init];
                    eventViewController.event = showing;
                    eventViewController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBackBarButtonItemWithAction:^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }];
                    [weakSelf.navigationController pushViewController:eventViewController animated:YES];
                }
            }];
        }
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFFilmViewControllerTableSectionPeople,
                MSTableSectionHeader : header,
                MSTableSectionRows : rows
            }];
        }
    }
    
    // Info Section
    {
        NSString *headerTitle = @"DETAILS";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFFilmReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        // Country
        if (self.film.country && ![self.film.country isEqualToString:@""]) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierCountry,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"COUNTRY";
                    cell.detail.text = weakSelf.film.country;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
            }];
        }
        
        // Year
        if (self.film.year && ![self.film.year isEqualToString:@""]) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierYear,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"YEAR";
                    cell.detail.text = weakSelf.film.year;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
            }];
        }
        
        // Language
        if (self.film.language && ![self.film.language isEqualToString:@""]) {
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
        if (self.film.runtime) {
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
        
        // Rating
        if (self.film.rating && ![self.film.rating isEqualToString:@""]) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierRuntime,
                MSTableClass : MSRightDetailGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
                    cell.title.text = @"RATING";
                    cell.detail.text = weakSelf.film.rating;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                }
             }];
        }
        
//        // Print Source
//        if (self.film.printSource && ![self.film.printSource isEqualToString:@""]) {
//            [rows addObject:@{
//                MSTableReuseIdentifer : SFFilmReuseIdentifierPrintSource,
//                MSTableClass : MSRightDetailGroupedTableViewCell.class,
//                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
//                    cell.title.text = @"PRINT SOURCE";
//                    cell.detail.text = weakSelf.film.printSource;
//                    cell.selectionStyle = MSTableCellSelectionStyleNone;
//                }
//             }];
//        }
//        
//        // Filmography
//        if (self.film.filmography && ![self.film.filmography isEqualToString:@""]) {
//            [rows addObject:@{
//                MSTableReuseIdentifer : SFFilmReuseIdentifierFilmography,
//                MSTableClass : MSRightDetailGroupedTableViewCell.class,
//                MSTableConfigurationBlock : ^(MSRightDetailGroupedTableViewCell *cell){
//                    cell.title.text = @"FILMOGRAPHY";
//                    cell.detail.text = weakSelf.film.filmography;
//                    cell.selectionStyle = MSTableCellSelectionStyleNone;
//                }
//             }];
//        }
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFFilmViewControllerTableSectionInfo,
                MSTableSectionHeader : header,
                MSTableSectionRows : rows,
             }];
        }
    }
    
    // People Section
    {
        NSString *headerTitle = @"PEOPLE";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFFilmReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        // Directors
        if (self.film.directors.count) {
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
        if (self.film.writers.count) {
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
        if (self.film.producers.count) {
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
        if (self.film.stars.count) {
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
                 MSTableSectionHeader : header,
                 MSTableSectionRows : rows
             }];
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
            [self prepareSections];
            break;
    }
}

@end

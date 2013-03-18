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
#import "SFNavigationBar.h"
#import "SFToolbar.h"

// Sections
NSString *const SFFilmViewControllerTableSectionTitle = @"Title";
NSString *const SFFilmViewControllerTableSectionDescription = @"Description";
NSString *const SFFilmViewControllerTableSectionInfo = @"Info";
NSString *const SFFilmViewControllerTableSectionPeople = @"People";
NSString *const SFFilmViewControllerTableSectionShowings = @"Showings";
NSString *const SFFilmViewControllerTableSectionActions = @"Actions";

// Reuse Identifiers
// Headers
NSString *const SFFilmReuseIdentifierHeader = @"Header";
// Title
NSString *const SFFilmReuseIdentifierTitle = @"Title";
// Actions
NSString *const SFFilmReuseIdentifierTickets = @"Tickets";
NSString *const SFFilmReuseIdentifierTrailer = @"Trailer";
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

@interface SFFilmViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayerViewController;

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
    
    __weak typeof (self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[SFStyleManager sharedManager] styledFavoriteBarButtonItemWithAction:^{
        weakSelf.film.favorite = @(![weakSelf.film.favorite boolValue]);
        [weakSelf.film.managedObjectContext save:nil];
    }];
    ((UIButton *)self.navigationItem.rightBarButtonItem.customView).selected = [weakSelf.film.favorite boolValue];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[SFStyleManager sharedManager] stylePopoverCollectionView:self.collectionView];
    } else {
        [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    }
    
    [self prepareSections];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - SFFilmViewController

- (void)prepareSections
{
    NSMutableArray *sections = [NSMutableArray new];
    __weak typeof (self) weakSelf = self;
    
    void(^playMovie)(NSString *movieURL) = ^(NSString *movieURL){
        
        void(^presentMoviePlayerViewController)(NSURL *contentURL) = ^(NSURL *contentURL) {
            weakSelf.moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:contentURL];
            [weakSelf.moviePlayerViewController.moviePlayer prepareToPlay];
            [weakSelf presentViewController:weakSelf.moviePlayerViewController animated:YES completion:nil];
        };
        
        void(^contentExtractionFailure)(NSError *error) = ^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Unable to Play Trailer" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
        };
        
        if ([movieURL rangeOfString:@"vimeo"].length != 0) {
            [YTVimeoExtractor fetchVideoURLFromURL:movieURL quality:YTVimeoVideoQualityMedium success:^(NSURL *contentURL) {
                presentMoviePlayerViewController(contentURL);
            } failure:^(NSError *error) {
                contentExtractionFailure(error);
            }];
        }
        else if ([movieURL rangeOfString:@"youtube"].length != 0) {
            NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:movieURL]];
            NSURL *contentURL = [NSURL URLWithString:[videos objectForKey:@"medium"]];
            if (contentURL) {
                presentMoviePlayerViewController(contentURL);
            } else {
                contentExtractionFailure([NSError errorWithDomain:@"" code:0 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid YouTube URL. Please try again later." }]);
            }
        } else {
            contentExtractionFailure([NSError errorWithDomain:@"" code:0 userInfo:@{ NSLocalizedDescriptionKey : @"URL is not hosted on YouTube or Vimeo. Please try again later." }]);
        }
    };
    
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
                    webViewController.scalesPageToFit = YES;
                    webViewController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U00002421" fontSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 28.0 : 24.0) action:^{
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }];
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
                    [navigationController addChildViewController:webViewController];
                    [weakSelf presentViewController:navigationController animated:YES completion:^{
                        [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
                    }];
                }
            }];
        }
        
        if (self.film.trailerURL && ![self.film.trailerURL isEqualToString:@""]) {
            [rows addObject:@{
                MSTableReuseIdentifer : SFFilmReuseIdentifierTrailer,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"TRAILER";
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath) {
                    playMovie(self.film.trailerURL);
                    [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
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
            NSString *title = [self.film directorsTitleString];
            NSString *detail = [self.film directorsListSeparatedByString:@"\n"];
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
            NSString *title = [self.film writersTitleString];
            NSString *detail = [self.film writersListSeparatedByString:@"\n"];
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
            NSString *title = [self.film producersTitleString];
            NSString *detail = [self.film producersListSeparatedByString:@"\n"];
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
            NSString *title = [self.film starsTitleString];
            NSString *detail = [self.film starsListSeparatedByString:@"\n"];
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

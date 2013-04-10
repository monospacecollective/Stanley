//
//  SFAttendViewController.m
//  Stanley
//
//  Created by Eric Horacek on 3/7/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFAttendViewController.h"
#import "SFStyleManager.h"
#import "SFWebViewController.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"

// Sections
NSString *const SFAttendTableSectionInformation = @"Information";
NSString *const SFAttendTableSectionPasses = @"Passes";
NSString *const SFAttendTableSectionSocial = @"Social";
NSString *const SFAttendTableSectionSupport = @"Support";

// Headers
NSString *const SFAttendReuseIdentifierHeader = @"Header";
// Information
NSString *const SFAttendReuseIdentifierPackages = @"Packages";
NSString *const SFAttendReuseIdentifierStandby = @"Standby";
NSString *const SFAttendReuseIdentifierBoxOffice = @"Box Office";
NSString *const SFAttendReuseIdentifierLodgingDining = @"Lodging Dining";
NSString *const SFAttendReuseIdentifierMerchandise = @"Merchandise";
NSString *const SFAttendReuseIdentifierFAQ = @"FAQ";
// Passes
NSString *const SFAttendReuseIdentifierPass = @"Pass";
NSString *const SFAttendReuseIdentifierPackage = @"Package";
NSString *const SFAttendReuseIdentifierHotel = @"Hotel";
// Social
NSString *const SFAttendReuseIdentifierFacebook = @"Facebook";
NSString *const SFAttendReuseIdentifierTwitter = @"Twitter";
NSString *const SFAttendReuseIdentifierInstagram = @"Instagram";
NSString *const SFAttendReuseIdentifierTellAFriend = @"Tell a Friend";
// Support
NSString *const SFAttendReuseIdentifierSponsor = @"Twitter";
NSString *const SFAttendReuseIdentifierVolunteer = @"Volunteer";

@interface SFAttendViewController ()

@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

- (void)prepareSections;

@end

@implementation SFAttendViewController

- (id)init
{
    self.collectionViewLayout = [[MSCollectionViewTableLayout alloc] init];
    self = [super initWithCollectionViewLayout:self.collectionViewLayout];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[SFStyleManager sharedManager] styleCollectionView:self.collectionView];
    [self prepareSections];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionViewLayout invalidateLayout];
}

#pragma mark - SFAttendViewController

- (void)prepareSections
{
    __weak typeof (self) weakSelf = self;
    
    void(^presentWebViewController)(NSString *requestURL, NSIndexPath *indexPath, BOOL scalesPageToFit) = ^(NSString *requestURL, NSIndexPath *indexPath, BOOL scalesPageToFit) {
        SFWebViewController *webViewController = [[SFWebViewController alloc] init];
        webViewController.scalesPageToFit = scalesPageToFit;
        webViewController.requestURL = requestURL;
        webViewController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U00002421" fontSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 28.0 : 24.0) action:^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
        [navigationController addChildViewController:webViewController];
        [weakSelf presentViewController:navigationController animated:YES completion:^{
            [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }];
    };
    
    NSMutableArray *sections = [NSMutableArray new];
    
    // Information
    {
        NSString *headerTitle = @"HOW TO FEST";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAttendReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierPackages,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"PASSES & TICKETS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/how-to-fest/passes-and-tickets/", indexPath, NO);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierStandby,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"QUEUE & STANDBY";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/how-to-fest/the-queue-system-rush-tickets-vouchers/", indexPath, NO);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierBoxOffice,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"BOX OFFICE";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/how-to-fest/box-office/", indexPath, NO);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierLodgingDining,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"LODGING & DINING";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/how-to-fest/lodging-dining/", indexPath, NO);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierMerchandise,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"MERCHANDISE";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/how-to-fest/merchandise-store/", indexPath, NO);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierFAQ,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"FAQ";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/how-to-fest/faq/", indexPath, NO);
            }
         }];
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFAttendTableSectionInformation,
                MSTableSectionRows : rows,
                MSTableSectionHeader : header
            }];
        }
    }
    
    // Passes
    {
        NSString *headerTitle = @"PASSES";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAttendReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierPass,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"BUY A PASS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://tickets.stanleyhotel.com/FilmFest/WebPages/EntaWebExtra/extralist.aspx", indexPath, YES);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierPackage,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"BUY A PACKAGE";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://booking.ihotelier.com/istay/istay.jsp?themeId=6272&hotelId=17440&ProdID=482715", indexPath, NO);
            }
         }];
        
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierHotel,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"BOOK STANLEY LODGING";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://bookings.ihotelier.com/The-Stanley-Hotel/bookings.jsp?hotelId=17440&themeId=6272&ProdID=482715", indexPath, NO);
            }
         }];
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFAttendTableSectionPasses,
                MSTableSectionRows : rows,
                MSTableSectionHeader : header
             }];
        }
    }
    
    // Social
    {
        NSString *headerTitle = @"SOCIAL";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAttendReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierFacebook,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"SFF ON FACEBOOK";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://www.facebook.com/StanleyFilmFest", indexPath, YES);
            }
        }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierTwitter,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"SFF ON TWITTER";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://twitter.com/StanleyFilmFest", indexPath, YES);
            }
        }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierTwitter,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"SFF ON INSTAGRAM";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://instagram.com/stanleyfilmfest/", indexPath, YES);
            }
        }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierTwitter,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"TELL A FRIEND";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                NSArray *activityItems = @[ [NSString stringWithFormat:@"Check out the Stanley Film Fest!"], [NSURL URLWithString:@"http://www.stanleyfilmfest.com"] ];
                UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                activityController.excludedActivityTypes = @[ UIActivityTypeAssignToContact, UIActivityTypePrint ];
                [weakSelf presentViewController:activityController animated:YES completion:^{
                    [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
                }];
            }
        }];
                
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFAttendTableSectionSocial,
                MSTableSectionRows : rows,
                MSTableSectionHeader : header
             }];
        }
    }
    
    // Support
    {
        NSString *headerTitle = @"SUPPORT";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAttendReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = headerTitle;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierSponsor,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"SPONSOR";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://www.stanleyfilmfest.com/sponsors/", indexPath, YES);
            }
        }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAttendReuseIdentifierVolunteer,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"VOLUNTEER";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://www.stanleyfilmfest.com/volunteer/", indexPath, YES);
            }
        }];
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFAttendTableSectionSupport,
                MSTableSectionRows : rows,
                MSTableSectionHeader : header
             }];
        }
    }
        
    self.collectionViewLayout.sections = sections;
}

@end

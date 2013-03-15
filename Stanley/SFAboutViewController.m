//
//  SFAboutViewController.m
//  Stanley
//
//  Created by Eric Horacek on 3/7/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFAboutViewController.h"
#import "SFStyleManager.h"
#import "SFWebViewController.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"

// Sections
NSString *const SFAboutTableSectionInformation = @"Information";
NSString *const SFAboutTableSectionAttend = @"Attend";
NSString *const SFAboutTableSectionContact = @"Contact";
NSString *const SFAboutTableSectionMission = @"Mission";
NSString *const SFAboutTableSectionArtistic = @"Artistic";
NSString *const SFAboutTableSectionStanley = @"Stanley";
NSString *const SFAboutTableSectionMonospace = @"Monospace";

// Reuse Identifiers
// Headers
NSString *const SFAboutReuseIdentifierHeader = @"Header";
// Information
NSString *const SFAboutReuseIdentifierPackages = @"Packages";
NSString *const SFAboutReuseIdentifierStandby = @"Standby";
NSString *const SFAboutReuseIdentifierBoxOffice = @"Box Office";
NSString *const SFAboutReuseIdentifierLodgingDining = @"Lodging Dining";
NSString *const SFAboutReuseIdentifierMerchandise = @"Merchandise";
NSString *const SFAboutReuseIdentifierFAQ = @"FAQ";
// Attend
NSString *const SFAboutReuseIdentifierPass = @"Pass";
NSString *const SFAboutReuseIdentifierPackage = @"Package";
// Contact
NSString *const SFAboutReuseIdentifierContactStaff = @"Contact Staff";
NSString *const SFAboutReuseIdentifierContactMonospace = @"Contact Monospace";
// About
NSString *const SFAboutReuseIdentifierMission = @"Mission";
NSString *const SFAboutReuseIdentifierArtistic = @"Artistic";
NSString *const SFAboutReuseIdentifierStanley = @"Stanley";
NSString *const SFAboutReuseIdentifierMonospace = @"Monospace";

@interface SFAboutViewController ()

@property (nonatomic, strong) MSCollectionViewTableLayout *collectionViewLayout;

@end

@implementation SFAboutViewController

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

#pragma mark - SFAboutViewController

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
    
    // Information Section
    {
        NSString *title = @"HOW TO FEST";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = title;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:title forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAboutReuseIdentifierPackages,
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
            MSTableReuseIdentifer : SFAboutReuseIdentifierStandby,
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
            MSTableReuseIdentifer : SFAboutReuseIdentifierBoxOffice,
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
            MSTableReuseIdentifer : SFAboutReuseIdentifierLodgingDining,
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
            MSTableReuseIdentifer : SFAboutReuseIdentifierMerchandise,
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
            MSTableReuseIdentifer : SFAboutReuseIdentifierFAQ,
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
                MSTableSectionIdentifier : SFAboutTableSectionInformation,
                MSTableSectionRows : rows,
                MSTableSectionHeader : header
            }];
        }
    }
    
    // Attend Section
    {
        NSString *title = @"ATTEND";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = title;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:title forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAboutReuseIdentifierPass,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"PASS";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://tickets.stanleyhotel.com/FilmFest/WebPages/EntaWebExtra/extralist.aspx", indexPath, YES);
            }
         }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAboutReuseIdentifierPackage,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"PACKAGE";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"https://booking.ihotelier.com/istay/istay.jsp?themeId=6272&hotelId=17440&ProdID=482715", indexPath, NO);
            }
         }];
        
        if (rows.count) {
            [sections addObject:@{
                MSTableSectionIdentifier : SFAboutTableSectionAttend,
                MSTableSectionRows : rows,
                MSTableSectionHeader : header
             }];
        }
    }
    
    // Contact Section
    {
        NSString *title = @"CONTACT";
        NSDictionary *header = @{
            MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
            MSTableClass : MSGroupedTableViewHeaderView.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                headerView.title.text = title;
            },
            MSTableSizeBlock : ^(CGFloat width) {
                return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:title forWidth:width]);
            }
        };
        
        NSMutableArray *rows = [NSMutableArray new];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAboutReuseIdentifierContactStaff,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"FESTIVAL STAFF";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://stanleyfilmfest.com/contact/festival-staff/", indexPath, NO);
            }
        }];
        
        [rows addObject:@{
            MSTableReuseIdentifer : SFAboutReuseIdentifierContactMonospace,
            MSTableClass : MSGroupedTableViewCell.class,
            MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                cell.title.text = @"MONOSPACE LTD.";
                cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
            },
            MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                presentWebViewController(@"http://monospacecollective.com/inquire", indexPath, NO);
            }
        }];
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFAboutTableSectionContact,
            MSTableSectionRows : rows,
            MSTableSectionHeader : header
        }];
    }
    
    // Mission Section
    {
        NSString *headerTitle = @"MISSION STATEMENT";
        
        NSString *cellTitle = @"The Stanley Film Festival showcases classic and contemporary independent horror cinema all set at the haunted and historic Stanley Hotel in beautiful Estes Park, Colorado. The Festival presents emerging and established filmmakers enabling the industry and general public to experience the power of storytelling through genre cinema. Founded in 2013 by The Stanley Hotel to celebrate the property’s iconic Hollywood heritage, the four-day event showcases filmmakers latest works, Q&A discussions, industry panels, the “Stanley Dean’s Cup” student film competition, and special events for cinema insiders, enthusiasts, and fellow artists.";
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFAboutTableSectionMission,
            MSTableSectionRows : @[@{
                MSTableReuseIdentifer : SFAboutReuseIdentifierMission,
                MSTableClass : MSMultlineGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                    cell.title.text = cellTitle;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:cellTitle forWidth:width]);
                }
            }],
            MSTableSectionHeader : @{
                MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
                MSTableClass : MSGroupedTableViewHeaderView.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                    headerView.title.text = headerTitle;
                },
                MSTableSizeBlock : ^(CGFloat width) {
                    return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
                }
            }
        }];
    }
    
    // Artistic Section
    {
        NSString *headerTitle = @"ARTISTIC STATEMENT";
        
        NSString *cellTitle = @"The Stanley Film Festival is a unique opportunity to showcase exhilarating voices in classic and contemporary horror within a haunted space chosen to amplify the experience beyond the terrors shown on screen. Armed with the goal of procuring the most imaginative tales of fright from around the globe, we will proudly present short and feature films that offer a vast spectrum of tantalizing thrills and ghastly delights throughout the weekend. Like the best spooky stories told in the dark, each will be wildly distinct, inventive and unexpected. The Stanley Hotel’s ghostly history as one of our eeriest landmarks, and its inspiration for some of cinema’s most unnerving spectacles, make this the perfect place to tempt the spirits and bring out your deepest fears in a way no other venue can. Enter if you dare, and let these films stay with you forever. And ever. And ever.";
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFAboutTableSectionArtistic,
            MSTableSectionRows : @[@{
                MSTableReuseIdentifer : SFAboutReuseIdentifierMission,
                MSTableClass : MSMultlineGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                    cell.title.text = cellTitle;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:cellTitle forWidth:width]);
                }
            }],
            MSTableSectionHeader : @{
                MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
                MSTableClass : MSGroupedTableViewHeaderView.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                    headerView.title.text = headerTitle;
                },
                MSTableSizeBlock : ^(CGFloat width) {
                    return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
                }
            }
        }];
    }
    
    // Stanley Section
    {
        NSString *headerTitle = @"THE STANLEY HOTEL";
        NSString *cellTitle = @"Famous for its old world charm, The Stanley Hotel boasts spectacular views in every direction and is less than six miles from Rocky Mountain National Park.  Multi-million dollar renovations have restored this 155-guestroom hotel to its original grandeur.  Listed on the National Register of Historic Places and member of Historic Hotels of America; only an hour away from Denver, it is ideal destination for a Colorado getaway.";
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFAboutTableSectionStanley,
            MSTableSectionRows : @[@{
                MSTableReuseIdentifer : SFAboutReuseIdentifierMission,
                MSTableClass : MSMultlineGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                    cell.title.text = cellTitle;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:cellTitle forWidth:width]);
                }
            }, @{
                MSTableReuseIdentifer : SFAboutReuseIdentifierContactStaff,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"WEBSITE";
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                    presentWebViewController(@"http://www.stanleyhotel.com", indexPath, YES);
                }
            }],
            MSTableSectionHeader : @{
                MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
                MSTableClass : MSGroupedTableViewHeaderView.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                    headerView.title.text = headerTitle;
                },
                MSTableSizeBlock : ^(CGFloat width) {
                    return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
                }
            }
        }];
    }
    
    // Monospace Section
    {
        NSString *headerTitle = @"MONOSPACE LTD.";
        NSString *cellTitle = @"Monospace Ltd. is a creative technology firm that specializes in delivering intuitive, beautiful, and useful solutions for clients and their customers. Our interest and expertise lies in development for both mobile and web.";
        
        [sections addObject:@{
            MSTableSectionIdentifier : SFAboutTableSectionMonospace,
            MSTableSectionRows : @[@{
                MSTableReuseIdentifer : SFAboutReuseIdentifierMonospace,
                MSTableClass : MSMultlineGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSMultlineGroupedTableViewCell *cell){
                    cell.title.text = cellTitle;
                    cell.selectionStyle = MSTableCellSelectionStyleNone;
                },
                MSTableSizeBlock : ^CGSize(CGFloat width){
                    return CGSizeMake(width, [MSMultlineGroupedTableViewCell heightForText:cellTitle forWidth:width]);
                }
            }, @{
                MSTableReuseIdentifer : SFAboutReuseIdentifierContactStaff,
                MSTableClass : MSGroupedTableViewCell.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewCell *cell){
                    cell.title.text = @"WEBSITE";
                    cell.accessoryType = MSTableCellAccessoryDisclosureIndicator;
                },
                MSTableItemSelectionBlock : ^(NSIndexPath *indexPath){
                    presentWebViewController(@"http://monospacecollective.com", indexPath, NO);
                }
            }],
            MSTableSectionHeader : @{
                MSTableReuseIdentifer : SFAboutReuseIdentifierHeader,
                MSTableClass : MSGroupedTableViewHeaderView.class,
                MSTableConfigurationBlock : ^(MSGroupedTableViewHeaderView *headerView) {
                    headerView.title.text = headerTitle;
                },
                MSTableSizeBlock : ^(CGFloat width) {
                    return CGSizeMake(width, [MSGroupedTableViewHeaderView heightForText:headerTitle forWidth:width]);
                }
            }
        }];
    }
        
    self.collectionViewLayout.sections = sections;
}

@end

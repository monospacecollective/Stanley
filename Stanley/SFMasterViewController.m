//
//  SFMasterViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFMasterViewController.h"
#import "SFStyleManager.h"
#import "SFNavigationBar.h"
#import "SFToolbar.h"
#import "SFMasterCell.h"
#import "SFFilmsViewController.h"
#import "SFEventsViewController.h"
#import "SFSplashViewController.h"
#import "SFMapViewController.h"
#import "SFAboutViewController.h"
#import "SFSocialViewController.h"

NSString * const SFMasterViewControllerCellReuseIdentifier = @"SFMasterViewControllerCellReuseIdentifier";

@interface SFMasterViewController () <MSNavigationPaneViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *paneTitles;
@property (nonatomic, strong) NSDictionary *paneIcons;
@property (nonatomic, strong) NSDictionary *paneClasses;

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

- (void)configureNavigationPaneForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (SFPaneType)paneTypeForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForPaneType:(SFPaneType)indexPath;

@end

@implementation SFMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.minimumLineSpacing = 0.0;
    self.collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    self.collectionViewLayout.itemSize = CGSizeMake(0.0, [SFMasterCell height]);
    self = [super initWithCollectionViewLayout:self.collectionViewLayout];
    if (self) {
        
        _paneType = NSUIntegerMax;
        
        self.paneTitles = @{
            @(SFPaneTypeFilms) : @"Films",
            @(SFPaneTypeEvents) : @"Events",
            @(SFPaneTypeSocial) : @"Social",
            @(SFPaneTypeMap) : @"Map",
            @(SFPaneTypeAbout) : @"About"
        };
        self.paneIcons = @{
            @(SFPaneTypeFilms) : @"\U0000E320",
            @(SFPaneTypeEvents) : @"\U0001F4C6",
            @(SFPaneTypeSocial) : @"\U0001F4AC",
            @(SFPaneTypeMap) : @"\U0000E673",
            @(SFPaneTypeAbout) : @"\U00002139"
        };
        self.paneClasses = @{
            @(SFPaneTypeFilms) : SFFilmsViewController.class,
            @(SFPaneTypeEvents) : SFEventsViewController.class,
            @(SFPaneTypeSocial) : SFSocialViewController.class,
            @(SFPaneTypeMap) : SFMapViewController.class,
            @(SFPaneTypeAbout) : SFAboutViewController.class
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.bounces = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:SFMasterCell.class forCellWithReuseIdentifier:SFMasterViewControllerCellReuseIdentifier];
    
    [self configureNavigationPaneForInterfaceOrientation:self.interfaceOrientation];
    self.navigationPaneViewController.delegate = self;
    
    NSUInteger paneType = [[NSUserDefaults standardUserDefaults] integerForKey:SFUserDefaultsCurrentPaneType];
    [self transitionToPane:paneType];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configureNavigationPaneForInterfaceOrientation:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureNavigationPaneForInterfaceOrientation:toInterfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait);
}

#pragma mark - SFMasterViewController

- (void)configureNavigationPaneForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.navigationPaneViewController.openDirection = (UIInterfaceOrientationIsPortrait(interfaceOrientation) ? MSNavigationPaneOpenDirectionTop : MSNavigationPaneOpenDirectionLeft);
    self.navigationPaneViewController.openStateRevealWidth = (UIInterfaceOrientationIsPortrait(interfaceOrientation) ? (self.collectionViewLayout.itemSize.height * SFPaneTypeCount) : 320.0);
    
    CGRect viewFrame = self.collectionView.frame;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        viewFrame.size.width = 320.0;
        viewFrame.size.height = self.collectionView.superview.frame.size.height;
    } else {
        viewFrame.size = self.collectionView.superview.frame.size;
    }
    self.collectionView.frame = viewFrame;
    [self.collectionView reloadData];
}

- (SFPaneType)paneTypeForIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row;
}

- (NSIndexPath *)indexPathForPaneType:(SFPaneType)paneType
{
    return [NSIndexPath indexPathForRow:paneType inSection:0];
}

- (void)transitionToPane:(SFPaneType)paneType
{
    if (paneType == self.paneType) {
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
        return;
    }
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    Class paneViewControllerClass = self.paneClasses[@(paneType)];
    NSParameterAssert([paneViewControllerClass isSubclassOfClass:UIViewController.class]);
    UIViewController *paneViewController = (UIViewController *)[[paneViewControllerClass alloc] init];
    
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 30.0 : 26.0);
    paneViewController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:self.paneIcons[@(paneType)] fontSize:fontSize action:^{
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES completion:nil];
    }];
    
    paneViewController.navigationItem.rightBarButtonItem = [[SFStyleManager sharedManager] styledLogoBarButtonItemWithAction:^{
        SFSplashViewController *splashViewController = [[SFSplashViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:splashViewController animated:YES completion:nil];
    }];
    
    paneViewController.navigationItem.title = [self.paneTitles[@(paneType)] uppercaseString];

    UINavigationController *paneNavigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:SFToolbar.class];
    [paneNavigationController addChildViewController:paneViewController];
    
    [((SFNavigationBar *)paneNavigationController.navigationBar) setShouldDisplayNavigationPaneDirectonLabel:YES];
    
    [self.navigationPaneViewController setPaneViewController:paneNavigationController animated:animateTransition completion:^{
        [[NSUserDefaults standardUserDefaults] setInteger:paneType forKey:SFUserDefaultsCurrentPaneType];
    }];
    self.paneType = paneType;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return SFPaneTypeCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFMasterCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:SFMasterViewControllerCellReuseIdentifier forIndexPath:indexPath];
    SFPaneType paneType = [self paneTypeForIndexPath:indexPath];
    cell.title.text = [self.paneTitles[@(paneType)] uppercaseString];
    cell.icon.text = self.paneIcons[@(paneType)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    CGFloat height = [SFMasterCell height];
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFPaneType paneType = [self paneTypeForIndexPath:indexPath];
    [self transitionToPane:paneType];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - MSNavigationPaneViewControllerDelegate

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    self.collectionView.scrollsToTop = (state == MSNavigationPaneStateOpen);
}

@end

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
#import "SFMasterTableViewCell.h"
#import "SFFilmsViewController.h"
#import "SFEventsViewController.h"
#import "SFNewsViewController.h"
#import "SFSplashViewController.h"

NSString * const SFMasterViewControllerCellReuseIdentifier = @"SFMasterViewControllerCellReuseIdentifier";

@interface SFMasterViewController () <MSNavigationPaneViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *paneTitles;
@property (nonatomic, strong) NSDictionary *paneIcons;
@property (nonatomic, strong) NSDictionary *paneClasses;

- (void)configureNavigationPaneForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (SFPaneType)paneTypeForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForPaneType:(SFPaneType)indexPath;

@end

@implementation SFMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _paneType = NSUIntegerMax;
        
        self.paneTitles = @{
            @(SFPaneTypeFilms) : @"Films",
            @(SFPaneTypeNews) : @"News",
            @(SFPaneTypeEvents) : @"Events",
            @(SFPaneTypeMap) : @"Map",
            @(SFPaneTypeCommunity) : @"Community"
        };
        self.paneIcons = @{
            @(SFPaneTypeFilms) : @"\U0000E320",
            @(SFPaneTypeNews) : @"\U00002709",
            @(SFPaneTypeEvents) : @"\U0001F4C6",
            @(SFPaneTypeMap) : @"\U0000E673",
            @(SFPaneTypeCommunity) : @"\U0001F4AC"
        };
        self.paneClasses = @{
            @(SFPaneTypeFilms) : SFFilmsViewController.class,
            @(SFPaneTypeNews) : SFNewsViewController.class,
            @(SFPaneTypeEvents) : SFEventsViewController.class,
            @(SFPaneTypeMap) : UITableViewController.class,
            @(SFPaneTypeCommunity) : UITableViewController.class
        };
    }
    return self;
}

- (void)loadView
{
    self.tableView = [[MSPlainTableView alloc] init];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollsToTop = NO;
    self.tableView.rowHeight = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 52.0 : 44.0);;
    [self.tableView registerClass:SFMasterTableViewCell.class forCellReuseIdentifier:SFMasterViewControllerCellReuseIdentifier];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self configureNavigationPaneForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - SFMAsterViewController

- (void)configureNavigationPaneForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.navigationPaneViewController.openDirection = (UIInterfaceOrientationIsPortrait(interfaceOrientation) ? MSNavigationPaneOpenDirectionTop : MSNavigationPaneOpenDirectionLeft);
    self.navigationPaneViewController.openStateRevealWidth = (UIInterfaceOrientationIsPortrait(interfaceOrientation) ? ((self.tableView.rowHeight * SFPaneTypeCount) + 20.0) : 320.0);
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.size.width = 320.0;
        self.tableView.frame = tableViewFrame;
    } else {
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.size = self.tableView.superview.frame.size;
        self.tableView.frame = tableViewFrame;
    }
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
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES];
        return;
    }
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    Class paneViewControllerClass = self.paneClasses[@(paneType)];
    NSParameterAssert([paneViewControllerClass isSubclassOfClass:UIViewController.class]);
    UIViewController *paneViewController = (UIViewController *)[[paneViewControllerClass alloc] init];
    paneViewController.navigationItem.leftBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:self.paneIcons[@(paneType)] action:^{
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES];
    }];
    
    paneViewController.navigationItem.rightBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithImage:[UIImage imageNamed:@"SFLogoBarButtonItemIcon"] action:^{
        
        SFSplashViewController *splashViewController = [[SFSplashViewController alloc] initWithNibName:nil bundle:nil];
        [self presentViewController:splashViewController animated:YES completion:nil];
    }];
    
    // Build navigation title with spaces between each character
    NSMutableString *navigationTitle = [self.paneTitles[@(paneType)] mutableCopy];
    for (NSUInteger characterIndex = 1; characterIndex < navigationTitle.length; characterIndex += 2) {
        [navigationTitle insertString:@" " atIndex:characterIndex];
    }
    paneViewController.navigationItem.title = [navigationTitle uppercaseString];

    UINavigationController *paneNavigationController = [[UINavigationController alloc] initWithNavigationBarClass:SFNavigationBar.class toolbarClass:UIToolbar.class];
    [paneNavigationController addChildViewController:paneViewController];
    
    [self.navigationPaneViewController setPaneViewController:paneNavigationController animated:animateTransition completion:^{
        [[NSUserDefaults standardUserDefaults] setInteger:paneType forKey:SFUserDefaultsCurrentPaneType];
    }];
    self.paneType = paneType;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SFPaneTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SFMasterViewControllerCellReuseIdentifier];
    SFPaneType paneType = [self paneTypeForIndexPath:indexPath];
    cell.textLabel.text = [self.paneTitles[@(paneType)] uppercaseString];
    cell.icon.text = self.paneIcons[@(paneType)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFPaneType paneType = [self paneTypeForIndexPath:indexPath];
    [self transitionToPane:paneType];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MSNavigationPaneViewControllerDelegate

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    self.tableView.scrollsToTop = (state == MSNavigationPaneStateOpen);
}

@end

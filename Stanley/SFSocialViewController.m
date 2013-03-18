//
//  SFSocialViewController.m
//  Stanley
//
//  Created by Devon Tivona on 3/13/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFSocialViewController.h"
#import "SFStyleManager.h"
#import "SFTweetCell.h"
#import "SFInstagramPhotoCell.h"

typedef NS_ENUM(NSUInteger, RSCommunityViewControllerType) {
    SFSocialTypeTwitter,
    SFSocialTypeInstagram,
    SFSocialTypeCount
};

@interface SFSocialViewController ()

- (void)setChildViewControllerAtIndex:(NSUInteger)index;

@property (nonatomic, strong) NSDictionary *childClasses;
@property (nonatomic, strong) NSDictionary *cellClasses;

@end

@implementation SFSocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.childClasses = @{
            @(SFSocialTypeTwitter) : MSTweetsViewController.class,
            @(SFSocialTypeInstagram) : MSInstagramPhotoViewController.class,
        };
        self.cellClasses = @{
            @(SFSocialTypeTwitter) : SFTweetCell.class,
            @(SFSocialTypeInstagram) : SFInstagramPhotoCell.class,
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.segmentedControl = [[SFStyleManager sharedManager] styledSegmentedControlWithTitles:@[@"TWITTER", @"INSTAGRAM"] action:^(NSUInteger newIndex) {
        [weakSelf setChildViewControllerAtIndex:newIndex];
    }];
    
    NSArray *toolbarItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
    ];
    
    self.toolbarItems = toolbarItems;
    [self.navigationController setToolbarHidden:NO];
    
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 28.0 : 24.0);
    self.navigationItem.rightBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U0001F4DD" fontSize:fontSize action:^{
        [weakSelf.currentChildViewController addNew];
    }];
    
    CGFloat height, width;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        height = self.view.frame.size.width;
        width = self.view.frame.size.height;
    } else {
        height = self.view.frame.size.height;
        width = self.view.frame.size.width;
    }
    
    self.view.frame = CGRectMake(0, 0, width, height);
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.containerView.backgroundColor = [UIColor redColor];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.containerView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setChildViewControllerAtIndex:0];
}

- (void)setChildViewControllerAtIndex:(NSUInteger)index
{
    RSCommunityViewControllerType communityViewControllerType = index;
    
    Class childViewControllerClass = self.childClasses[@(communityViewControllerType)];
    NSParameterAssert([childViewControllerClass isSubclassOfClass:UIViewController.class]);
    UICollectionViewController <MSSocialChildViewController> *childViewController = (UICollectionViewController <MSSocialChildViewController> *)[[childViewControllerClass alloc] init];
    
    [childViewController setCellClass:self.cellClasses[@(communityViewControllerType)]];
    
    [self.currentChildViewController willMoveToParentViewController:nil];
    [self addChildViewController:childViewController];
    [childViewController view].frame = CGRectMake(0.0, 0.0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    CGFloat duration = 0.8;
    
    childViewController.collectionView.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];

    childViewController.refreshControl.layer.shadowColor = [[UIColor blackColor] CGColor];
    childViewController.refreshControl.layer.shadowOpacity = 1.0;
    childViewController.refreshControl.layer.shadowRadius = 3.0;
    childViewController.refreshControl.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    childViewController.refreshControl.tintColor = [UIColor colorWithHexString:@"404040"];
    
    if (self.currentChildViewController == nil) {
        [self.containerView addSubview:[childViewController view]];
        [childViewController didMoveToParentViewController:self];
        self.currentChildViewController = (UIViewController<MSSocialChildViewController> *)childViewController;
    } else {
        [UIView transitionFromView:self.currentChildViewController.view
                            toView:[childViewController view]
                          duration:duration
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            [self.currentChildViewController removeFromParentViewController];
                            [childViewController didMoveToParentViewController:self];
                            self.currentChildViewController = (UIViewController<MSSocialChildViewController> *)childViewController;
                        }];
        
    }
}

@end

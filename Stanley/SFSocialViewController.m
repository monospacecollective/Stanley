//
//  SFSocialViewController.m
//  Stanley
//
//  Created by Devon Tivona on 3/13/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFSocialViewController.h"
#import "SFStyleManager.h"

#import "MSTweetsViewController.h"
#import "MSInstagramPhotoViewController.h"
#import "MSSocialKitManager.h"

typedef NS_ENUM(NSUInteger, RSCommunityViewControllerType) {
    SFSocialTypeTwitter,
    SFSocialTypeInstagram,
    SFSocialTypeCount
};

@interface SFSocialViewController ()

- (void)setChildViewControllerAtIndex:(NSUInteger)index;

@property (nonatomic, strong) NSDictionary *childClasses;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentedControl = [[SFStyleManager sharedManager] styledSegmentedControlWithTitles:@[@"TWITTER", @"INSTAGRAM"] action:^(NSUInteger newIndex) {
        [self setChildViewControllerAtIndex:newIndex];
    }];
    
    NSArray *toolbarItems = @[
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl],
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              ];
    
    self.toolbarItems = toolbarItems;
    [self.navigationController setToolbarHidden:NO];
    
    self.navigationItem.rightBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U0001F4DD" action:^{
        [self.currentChildViewController addNew];
    }];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ((UIButton *)self.navigationItem.rightBarButtonItem.customView).contentEdgeInsets = UIEdgeInsetsMake(-7.0, 0.0, 0.0, 0.0);
    }
    
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
    UIViewController *childViewController = (UIViewController *)[[childViewControllerClass alloc] init];
    
    [self.currentChildViewController willMoveToParentViewController:nil];
    [self addChildViewController:childViewController];
    childViewController.view.frame = CGRectMake(0.0, 0.0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    
    CGFloat duration = 0.8;
    
    if (self.currentChildViewController == nil) {
        [self.containerView addSubview:childViewController.view];
        [childViewController didMoveToParentViewController:self];
        self.currentChildViewController = (UIViewController<MSSocialChildViewController> *)childViewController;
    } else {
        [UIView transitionFromView:self.currentChildViewController.view
                            toView:childViewController.view
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

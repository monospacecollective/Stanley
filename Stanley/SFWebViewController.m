//
//  SFWebViewController.m
//  Stanley
//
//  Created by Eric Horacek on 3/8/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFWebViewController.h"
#import "SFTryAgainView.h"
#import "SFStyleManager.h"
#import "SFNavigationBar.h"

@interface SFWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) SFTryAgainView *tryAgainView;

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *reloadBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *loadingBarButtonItem;

- (void)updateWebViewControls;

@end

@implementation SFWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[SFStyleManager sharedManager] viewBackgroundColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.opaque = NO;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = self.scalesPageToFit;
    [self.view addSubview:self.webView];
    [self loadRequest];
    
    [self.navigationController setToolbarHidden:NO];
    
    __weak typeof (self) weakSelf = self;
    
    self.backBarButtonItem = [[SFStyleManager sharedManager] styledBackBarButtonItemWithAction:^{
        if (weakSelf.webView.canGoBack) {
            [weakSelf.webView goBack];
        }
    }];
    
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 28.0 : 24.0);
    
    self.forwardBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U000027A1" fontSize:fontSize action:^{
        if (weakSelf.webView.canGoForward) {
            [weakSelf.webView goForward];
        }
    }];
    
    self.reloadBarButtonItem = [[SFStyleManager sharedManager] styledBarButtonItemWithSymbolsetTitle:@"\U000021BB" fontSize:fontSize action:^{
        if ([weakSelf.webView isLoading] == NO) {
            [weakSelf.webView reload];
        }
    }];
    
    self.loadingBarButtonItem = [[SFStyleManager sharedManager] activityIndicatorBarButtonItem];
    
    [self updateWebViewControls];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setShouldDisplayNavigationPaneDirectonLabel:)]) {
        [((SFNavigationBar *)self.navigationController.navigationBar) setShouldDisplayNavigationPaneDirectonLabel:NO];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.webView.frame = (CGRect){CGPointZero, self.view.frame.size};
    self.tryAgainView.frame = (CGRect){CGPointZero, self.view.frame.size};
}

#pragma mark - SFWebViewController

- (void)updateWebViewControls
{
    NSMutableArray *items = [NSMutableArray array];
    
    if ([self.webView canGoBack]) {
        [items addObject:self.backBarButtonItem];
    }
    
    if ([self.webView canGoForward]) {
        [items addObject:self.forwardBarButtonItem];
    }
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    
    if (self.webView.isLoading) {
        [items addObject:self.loadingBarButtonItem];
        self.navigationItem.title = @"LOADING...";
    } else {
        [items addObject:self.reloadBarButtonItem];
        self.navigationItem.title = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"] uppercaseString];
    }
    
    self.toolbarItems = items;
}

- (void)loadRequest
{
    NSParameterAssert(self.requestURL != nil);
    NSURLRequest *URLRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.requestURL]];
    [self.webView loadRequest:URLRequest];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self updateWebViewControls];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateWebViewControls];
    
    // Remove the try again view if it exists
    if (self.tryAgainView) {
        [self.tryAgainView removeFromSuperview];
        self.tryAgainView = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Loading %@ failed with error \"%@\"", error.userInfo[NSURLErrorFailingURLStringErrorKey], [error localizedDescription]);
    
    [self updateWebViewControls];
    
    // Add the try again view if it doesn't already exist
    if (!self.tryAgainView) {
        self.tryAgainView = [[SFTryAgainView alloc] initWithFrame:self.webView.frame];
        __weak typeof(self) weakSelf = self;
        [self.tryAgainView.tryAgainButton addEventHandler:^{
            [weakSelf loadRequest];
        } forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:self.tryAgainView aboveSubview:self.webView];
    }
    
    self.tryAgainView.subtitleLabel.text = error.localizedDescription;
}

@end

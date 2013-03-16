//
//  SFSplashViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/16/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFSplashViewController.h"
#import "SFLogoView.h"
#import "SFStyleManager.h"

@interface SFSplashViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) SFLogoView *logoView;
@property (nonatomic, strong) UILabel *taglineLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIView *border;

@end

@implementation SFSplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *backgroundImage = [UIImage imageNamed:@"SFSplashBackground.jpg"];
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.image = backgroundImage;
    self.backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.border = [UIView new];
    self.border.backgroundColor = [UIColor clearColor];
    self.border.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.border.layer.borderWidth = 1.0;
    [self.view addSubview:self.border];
    
    self.logoView = [SFLogoView new];
    [self.view addSubview:self.logoView];
    
    self.taglineLabel = [UILabel new];
    self.taglineLabel.text = [@"Yeah, it's\nCreepy\n\nMay 2 - 5" uppercaseString];
    self.taglineLabel.numberOfLines = 0;
    self.taglineLabel.textAlignment = NSTextAlignmentCenter;
    self.taglineLabel.backgroundColor = [UIColor clearColor];
    self.taglineLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.taglineLabel];
    
    self.doneButton = [UIButton new];
    [self.doneButton setTitle:[@"Enter" uppercaseString] forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.doneButton.backgroundColor = [UIColor blackColor];
    self.doneButton.contentEdgeInsets = UIEdgeInsetsMake(13.0, 30.0, 7.0, 30.0);
    __weak typeof (self) weakSelf = self;
    [self.doneButton addEventHandler:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    BOOL iphone568 = (UIScreen.mainScreen.bounds.size.height == 568.0);

    CGFloat borderInsetSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20.0 : 10.0);
    self.border.frame = CGRectInset((CGRect){CGPointZero, self.backgroundImageView.frame.size}, borderInsetSize, borderInsetSize);
    
    self.logoView.stanleyFontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 60.0 : 50.0) : (iphone568 ? 34.0 : 28.0));
    [self.logoView sizeToFit];
    CGRect logoViewFrame = self.logoView.frame;
    logoViewFrame.origin.y = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 120.0 : 100.0) : (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 50.0 : 30.0));
    logoViewFrame.origin.x = floorf((CGRectGetWidth(self.backgroundImageView.frame) / 2.0) - (CGRectGetWidth(logoViewFrame) / 2.0));
    self.logoView.frame = logoViewFrame;
    
    self.taglineLabel.font = [[SFStyleManager sharedManager] titleFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 50.0 : 40.0) : (iphone568 ? 28.0 : 24.0))];
    CGSize taglineLabelSize = [self.taglineLabel sizeThatFits:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? CGSizeMake(400.0, 400.0) : CGSizeMake(280.0, 280.0))];
    CGRect taglineLabelFrame = self.taglineLabel.frame;
    taglineLabelFrame.size = taglineLabelSize;
    taglineLabelFrame.origin.y = floorf((CGRectGetHeight(self.backgroundImageView.frame) / 2.0) - (CGRectGetHeight(taglineLabelFrame) / 2.0)) + ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70.0 : 30.0);
    taglineLabelFrame.origin.x = floorf((CGRectGetWidth(self.backgroundImageView.frame) / 2.0) - (CGRectGetWidth(taglineLabelFrame) / 2.0));
    self.taglineLabel.frame = taglineLabelFrame;
    
    self.doneButton.titleLabel.font = [[SFStyleManager sharedManager] titleFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24.0 : (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 20.0 : 16.0))];
    [self.doneButton sizeToFit];
    CGRect doneButtonFrame = self.doneButton.frame;
    doneButtonFrame.origin.y = CGRectGetHeight(self.backgroundImageView.frame) - CGRectGetHeight(doneButtonFrame) - ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 120.0 : 100.0) : (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 50.0 : 30.0));
    doneButtonFrame.origin.x = floorf((CGRectGetWidth(self.backgroundImageView.frame) / 2.0) - (CGRectGetWidth(doneButtonFrame) / 2.0));
    self.doneButton.frame = doneButtonFrame;
}

@end

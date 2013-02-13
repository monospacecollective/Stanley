//
//  SFStyleManager.m
//  Stanley
//
//  Created by Eric Horacek on 2/11/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFStyleManager.h"

static SFStyleManager *singletonInstance = nil;

@implementation SFStyleManager

+ (instancetype)sharedManager
{
    if (!singletonInstance) {
        singletonInstance = [[[self class] alloc] init];
    }
    return singletonInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[UITableView appearance] setBackgroundColor:[self viewBackgroundColor]];
        
        [MSPlainTableViewCell.appearance setEtchHighlightColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
        [MSPlainTableViewCell.appearance setEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewCell.appearance setSelectionColor:[UIColor colorWithWhite:0.0 alpha:0.5]];

        [MSPlainTableViewCell.appearance setHighlightViewHeight:1.0];
        [MSPlainTableViewCell.appearance setShadowViewHeight:2.0];
        
        [MSPlainTableViewHeaderView.appearance setTopEtchHighlightColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
        [MSPlainTableViewHeaderView.appearance setTopEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewHeaderView.appearance setBottomEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewHeaderView.appearance setBackgroundColor:[[UIColor colorWithWhite:0.0 alpha:1.0] colorWithNoiseWithOpacity:0.05 andBlendMode:kCGBlendModeScreen]];
        
        CAGradientLayer *defaultBackgroundGradient = [CAGradientLayer layer];
        UIColor *gradientTopColor = [UIColor colorWithWhite:1.0 alpha:0.05];
        UIColor *gradientBottomColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        defaultBackgroundGradient.colors = @[(id)[gradientTopColor CGColor], (id)[gradientBottomColor CGColor]];
        [MSPlainTableViewHeaderView.appearance setBackgroundGradient:defaultBackgroundGradient];
        
        UIFont *textFont = [self titleFontOfSize:18.0];
        UIFont *accessoryFont = [self symbolSetFontOfSize:16.0];
        UIColor *textColor = [UIColor whiteColor];
        NSValue *textShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        UIColor *textShadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        
        NSDictionary *textAttributes = @{ UITextAttributeFont : textFont, UITextAttributeTextColor : textColor, UITextAttributeTextShadowColor : textShadowColor, UITextAttributeTextShadowOffset : textShadowOffset };
        
        [MSTableViewCell.appearance setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [MSTableViewCell.appearance setAccessoryTextAttributes:@{ UITextAttributeFont : accessoryFont , UITextAttributeTextColor : textColor, UITextAttributeTextShadowColor : textShadowColor, UITextAttributeTextShadowOffset : textShadowOffset} forState:UIControlStateNormal];
        
        [MSTableViewCell.appearance setTitleTextAttributes:@{ UITextAttributeFont : textFont, UITextAttributeTextColor : [UIColor lightGrayColor], UITextAttributeTextShadowColor : textShadowColor, UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0.0, 1.0)] } forState:UIControlStateHighlighted];
        [MSTableViewCell.appearance setAccessoryTextAttributes:@{ UITextAttributeFont : accessoryFont, UITextAttributeTextColor : [UIColor lightGrayColor], UITextAttributeTextShadowColor : textShadowColor, UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0.0, 1.0)] } forState:UIControlStateHighlighted];
        
        [MSPlainTableViewHeaderView.appearance setTitleTextAttributes:textAttributes];
        
    }
    return self;
}

#pragma mark - Colors

- (UIColor *)viewBackgroundColor
{
    return [[UIColor colorWithHexString:@"1c1c1c"] colorWithNoiseWithOpacity:0.025 andBlendMode:kCGBlendModeScreen];
}

#pragma mark - Fonts

- (UIFont *)symbolSetFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"SS Standard" size:size];
}

- (UIFont *)navigationFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"FuturaCom-Bold" size:size];
}

- (UIFont *)titleFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"FuturaCom-Bold" size:size];
}

- (UIFont *)subtitleFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Futura-Medium" size:size];
}

#pragma mark - UICollectionView

- (void)styleCollectionView:(UICollectionView *)collectionView
{
    collectionView.backgroundColor = [self viewBackgroundColor];
    collectionView.backgroundView = nil;
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

#pragma mark - UIBarButtonItem Custom Views

- (void)styleBarButtonItemCustomView:(UIButton *)button
{
    //    UIEdgeInsets buttonBackgroundImageCapInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
    //    UIImage *backgroundImage = [[UIImage imageNamed:@"ELBarBackgroundItemCustomViewBackground"] resizableImageWithCapInsets:buttonBackgroundImageCapInsets];
    //    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    //    UIImage *highlightedBackgroundImage = [[UIImage imageNamed:@"ELBarBackgroundItemCustomViewPressedBackground"] resizableImageWithCapInsets:buttonBackgroundImageCapInsets];
    //    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
}

- (void)styleBackBarButtonItemCustomView:(UIButton *)button
{
    //    UIEdgeInsets buttonBackgroundImageCapInsets = UIEdgeInsetsMake(6.0, 13.0, 6.0, 6.0);
    //    UIImage *backgroundImage = [[UIImage imageNamed:@"ELBackBarBackgroundItemCustomViewBackground"] resizableImageWithCapInsets:buttonBackgroundImageCapInsets];
    //    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    //    UIImage *highlightedBackgroundImage = [[UIImage imageNamed:@"ELBackBarBackgroundItemCustomViewPressedBackground"] resizableImageWithCapInsets:buttonBackgroundImageCapInsets];
    //    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
}

- (void)styleBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title
{
    [self styleBarButtonItemCustomView:button];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    button.titleLabel.shadowColor = [UIColor blackColor];
    button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1.0, 11.0, 0.0, 11.0);
    [button sizeToFit];
}

- (void)styleBackBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title
{
    [self styleBackBarButtonItemCustomView:button];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    button.titleLabel.shadowColor = [UIColor blackColor];
    button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(1.0, 15.0, 0.0, 9.0);
    [button sizeToFit];
}

- (void)styleBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title
{
    [self styleBarButtonItemCustomView:button withTitle:title];
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 30.0 : 24.0);
    button.titleLabel.font = [self symbolSetFontOfSize:fontSize];
    button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 11.0, 0.0, 11.0);
    [button sizeToFit];
}

- (void)styleBackBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title
{
    [self styleBackBarButtonItemCustomView:button withTitle:title];
    button.titleLabel.font = [self symbolSetFontOfSize:16.0];
    button.contentEdgeInsets = UIEdgeInsetsMake(6.0, 13.0, 0.0, 8.0);
    [button sizeToFit];
}

#pragma mark - UIBarButtonItem

- (UIBarButtonItem *)styledBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self styleBarButtonItemCustomView:button withTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

- (UIBarButtonItem *)styledBackBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self styleBackBarButtonItemCustomView:button withTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

- (UIBarButtonItem *)styledBarButtonItemWithSymbolsetTitle:(NSString *)title action:(void(^)(void))handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self styleBarButtonItemCustomView:button withSymbolsetTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

- (UIBarButtonItem *)styledBackBarButtonItemWithSymbolsetTitle:(NSString *)title action:(void(^)(void))handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self styleBackBarButtonItemCustomView:button withSymbolsetTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}


@end

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
        
        [MSPlainTableViewCell.appearance setEtchHighlightColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [MSPlainTableViewCell.appearance setEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewCell.appearance setSelectionColor:[UIColor colorWithWhite:0.0 alpha:0.5]];

        [MSPlainTableViewCell.appearance setHighlightViewHeight:1.0];
        [MSPlainTableViewCell.appearance setShadowViewHeight:2.0];
        
        [MSPlainTableViewCell.appearance setAccessoryCharacter:@"\U000025BB" forAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [MSPlainTableViewCell.appearance setAccessoryCharacter:@"\U00002713" forAccessoryType:UITableViewCellAccessoryCheckmark];
        
        [MSPlainTableViewHeaderView.appearance setTopEtchHighlightColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
        [MSPlainTableViewHeaderView.appearance setTopEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewHeaderView.appearance setBottomEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewHeaderView.appearance setBackgroundColor:[self secondaryViewBackgroundColor]];
        
        UIFont *titleTextFont = [self titleFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20.0 : 17.0)];
        UIFont *detailTextFont = [self detailFontOfSize:15.0];
        UIFont *accessoryFont = [self symbolSetFontOfSize:15.0];
        UIColor *textColor = [UIColor whiteColor];
        UIColor *detailTextColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        NSValue *textShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        UIColor *textShadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        
        // Normal State
        [MSTableViewCell.appearance setTitleTextAttributes:@{
                                      UITextAttributeFont : titleTextFont,
                                 UITextAttributeTextColor : textColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : textShadowOffset }
                                                  forState:UIControlStateNormal];
        
        [MSTableViewCell.appearance setDetailTextAttributes:@{
                                      UITextAttributeFont : detailTextFont,
                                 UITextAttributeTextColor : detailTextColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : textShadowOffset }
                                                  forState:UIControlStateNormal];
        
        [MSTableViewCell.appearance setAccessoryTextAttributes:@{
                                          UITextAttributeFont : accessoryFont,
                                     UITextAttributeTextColor : textColor,
                               UITextAttributeTextShadowColor : textShadowColor,
                              UITextAttributeTextShadowOffset : textShadowOffset }
                                                      forState:UIControlStateNormal];
        
        UIColor *highlightedTextColor = [UIColor lightGrayColor];
        NSValue *highlightedTextShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        
        // Highlighted State
        [MSTableViewCell.appearance setTitleTextAttributes:@{
                                      UITextAttributeFont : titleTextFont,
                                 UITextAttributeTextColor : highlightedTextColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : highlightedTextShadowOffset }
                                                  forState:UIControlStateHighlighted];
        
        [MSTableViewCell.appearance setDetailTextAttributes:@{
                                      UITextAttributeFont : detailTextFont,
                                 UITextAttributeTextColor : highlightedTextColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : highlightedTextShadowOffset }
                                                  forState:UIControlStateHighlighted];
        
        [MSTableViewCell.appearance setAccessoryTextAttributes:@{
                                          UITextAttributeFont : accessoryFont,
                                     UITextAttributeTextColor : highlightedTextColor,
                               UITextAttributeTextShadowColor : textShadowColor,
                              UITextAttributeTextShadowOffset : highlightedTextShadowOffset }
                                                      forState:UIControlStateHighlighted];
        
        // Header View
        UIFont *headerTitleTextFont = [self detailFontOfSize:14.0];
        UIFont *headerDetailTextFont = [self detailFontOfSize:14.0];
        UIColor *headerDetailTextColor = [UIColor lightGrayColor];
        NSValue *headerTextShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        
        [MSTableViewHeaderFooterView.appearance setTitleTextAttributes:@{
                                                 UITextAttributeFont : headerTitleTextFont,
                                            UITextAttributeTextColor : headerDetailTextColor,
                                      UITextAttributeTextShadowColor : textShadowColor,
                                     UITextAttributeTextShadowOffset : headerTextShadowOffset }];
        
        [MSTableViewHeaderFooterView.appearance setDetailTextAttributes:@{
                                                  UITextAttributeFont : headerDetailTextFont,
                                             UITextAttributeTextColor : headerDetailTextColor,
                                       UITextAttributeTextShadowColor : textShadowColor,
                                      UITextAttributeTextShadowOffset : headerTextShadowOffset }];
        
    }
    return self;
}

#pragma mark - Colors

- (UIColor *)viewBackgroundColor
{
    return [[UIColor colorWithHexString:@"1c1c1c"] colorWithNoiseWithOpacity:0.025 andBlendMode:kCGBlendModeScreen];
}

- (UIColor *)secondaryViewBackgroundColor
{
    return [UIColor colorWithHexString:@"303030"];
}

- (UIColor *)primaryTextColor;
{
    return [UIColor colorWithHexString:@"ffffff"];
}

- (UIColor *)secondaryTextColor
{
    return [UIColor colorWithHexString:@"aaaaaa"];
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

- (UIFont *)detailFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Futura-Medium" size:size];
}

#pragma mark - UICollectionView

- (void)styleCollectionView:(PSUICollectionView *)collectionView
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
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
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

- (void)styleBarButtonItemCustomView:(UIButton *)button withImage:(UIImage *)image
{
    [self styleBarButtonItemCustomView:button];
    [button setImage:image forState:UIControlStateNormal];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 14.0, 5.0);
    } else {
        button.contentEdgeInsets = UIEdgeInsetsMake(2.0, 5.0, 5.0, 5.0);
    }
    [button sizeToFit];
}

- (void)styleBackBarButtonItemCustomView:(UIButton *)button withImage:(UIImage *)image
{
    [self styleBarButtonItemCustomView:button];
    [button setImage:image forState:UIControlStateNormal];
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

- (UIBarButtonItem *)styledBarButtonItemWithImage:(UIImage *)image action:(void(^)(void))handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self styleBarButtonItemCustomView:button withImage:image];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

- (UIBarButtonItem *)styledBackBarButtonItemWithImage:(UIImage *)image action:(void(^)(void))handler
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self styleBackBarButtonItemCustomView:button withImage:image];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

@end

//
//  SFStyleManager.m
//  Stanley
//
//  Created by Eric Horacek on 2/11/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFStyleManager.h"
#import "SFMasterViewController.h"

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

        [MSPlainTableViewHeaderView.appearance setTopEtchHighlightHeight:1.0];
        [MSPlainTableViewHeaderView.appearance setBottomEtchShadowHeight:2.0];
        
        [MSTableCell.appearance setAccessoryCharacter:@"\U000025BB" forAccessoryType:MSTableCellAccessoryDisclosureIndicator];
        [MSTableCell.appearance setAccessoryCharacter:@"\U00002713" forAccessoryType:MSTableCellAccessoryCheckmark];
        [MSTableCell.appearance setAccessoryCharacter:@"\U000022C6" forAccessoryType:MSTableCellAccessoryStarFull];
        [MSTableCell.appearance setAccessoryCharacter:@"\U0001F6AB" forAccessoryType:MSTableCellAccessoryStarEmpty];
        
        [MSPlainTableViewHeaderView.appearance setTopEtchHighlightColor:[UIColor colorWithWhite:1.0 alpha:0.1]];
        [MSPlainTableViewHeaderView.appearance setBottomEtchShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [MSPlainTableViewHeaderView.appearance setBackgroundColor:[self secondaryViewBackgroundColor]];
        
        UIFont *plainTitleFont = [self titleFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20.0 : 18.0)];
        UIFont *plainDetailFont = [self detailFontOfSize:15.0];
        UIFont *plainAccessoryFont = [self symbolSetFontOfSize:15.0];
        UIColor *textColor = [UIColor whiteColor];
        UIColor *detailTextColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        NSValue *textShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        UIColor *textShadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        
        // Normal State
        [MSPlainTableViewCell.appearance setTitleTextAttributes:@{
                                      UITextAttributeFont : plainTitleFont,
                                 UITextAttributeTextColor : textColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : textShadowOffset }
                                                  forState:UIControlStateNormal];
        
        [MSPlainTableViewCell.appearance setDetailTextAttributes:@{
                                      UITextAttributeFont : plainDetailFont,
                                 UITextAttributeTextColor : detailTextColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : textShadowOffset }
                                                  forState:UIControlStateNormal];
        
        [MSPlainTableViewCell.appearance setAccessoryTextAttributes:@{
                                          UITextAttributeFont : plainAccessoryFont,
                                     UITextAttributeTextColor : textColor,
                               UITextAttributeTextShadowColor : textShadowColor,
                              UITextAttributeTextShadowOffset : textShadowOffset }
                                                      forState:UIControlStateNormal];
        
        UIColor *highlightedTextColor = [UIColor lightGrayColor];
        NSValue *highlightedTextShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        
        // Highlighted State
        [MSPlainTableViewCell.appearance setTitleTextAttributes:@{
                                      UITextAttributeFont : plainTitleFont,
                                 UITextAttributeTextColor : highlightedTextColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : highlightedTextShadowOffset }
                                                  forState:UIControlStateHighlighted];
        
        [MSPlainTableViewCell.appearance setDetailTextAttributes:@{
                                      UITextAttributeFont : plainDetailFont,
                                 UITextAttributeTextColor : highlightedTextColor,
                           UITextAttributeTextShadowColor : textShadowColor,
                          UITextAttributeTextShadowOffset : highlightedTextShadowOffset }
                                                  forState:UIControlStateHighlighted];
        
        [MSPlainTableViewCell.appearance setAccessoryTextAttributes:@{
                                          UITextAttributeFont : plainAccessoryFont,
                                     UITextAttributeTextColor : highlightedTextColor,
                               UITextAttributeTextShadowColor : textShadowColor,
                              UITextAttributeTextShadowOffset : highlightedTextShadowOffset }
                                                      forState:UIControlStateHighlighted];
        
        
        // Grouped Cells
        [MSGroupedCellBackgroundView.appearance setBorderColor:[UIColor colorWithHexString:@"535353"] forState:UIControlStateNormal];
        [MSGroupedCellBackgroundView.appearance setFillColor:[UIColor colorWithHexString:@"404040"] forState:UIControlStateNormal];
        [MSGroupedCellBackgroundView.appearance setShadowColor:[UIColor colorWithHexString:@"000000"] forState:UIControlStateNormal];
        [MSGroupedCellBackgroundView.appearance setShadowOffset:CGSizeMake(0.0, 2.0) forState:UIControlStateNormal];
        [MSGroupedCellBackgroundView.appearance setInnerShadowColor:[UIColor colorWithHexString:@"404040"] forState:UIControlStateNormal];
        [MSGroupedCellBackgroundView.appearance setInnerShadowOffset:CGSizeMake(0.0, -1.0) forState:UIControlStateNormal];
        
        [MSGroupedCellBackgroundView.appearance setBorderColor:[UIColor colorWithHexString:@"000000"] forState:UIControlStateHighlighted];
        [MSGroupedCellBackgroundView.appearance setFillColor:[UIColor colorWithHexString:@"363636"] forState:UIControlStateHighlighted];
        [MSGroupedCellBackgroundView.appearance setShadowColor:[UIColor colorWithHexString:@"393939"] forState:UIControlStateHighlighted];
        [MSGroupedCellBackgroundView.appearance setShadowOffset:CGSizeMake(0.0, 1.0) forState:UIControlStateHighlighted];
        [MSGroupedCellBackgroundView.appearance setInnerShadowColor:[UIColor colorWithHexString:@"101010"] forState:UIControlStateHighlighted];
        [MSGroupedCellBackgroundView.appearance setInnerShadowOffset:CGSizeMake(0.0, 2.0) forState:UIControlStateHighlighted];
        [MSGroupedCellBackgroundView.appearance setInnerShadowBlur:2.0 forState:UIControlStateHighlighted];
        
        [MSGroupedCellBackgroundView.appearance setCornerRadius:2.0];
        
        [MSGroupedTableViewCell class];
        [MSRightDetailGroupedTableViewCell class];
        [MSMultilineRightDetailGroupedTableViewCell class];
        
        [MSGroupedTableViewCell.appearance setPadding:UIEdgeInsetsMake(13.0, 20.0, 7.0, 20.0)];
        
        UIFont *groupedTitleFont = [self titleFontOfSize:17.0];
        UIFont *groupedDetailFont = [self detailFontOfSize:16.0];
        UIFont *groupedAccessoryFont = [self symbolSetFontOfSize:16.0];
        [MSMultlineGroupedTableViewCell.appearance setTitleTextAttributes:@{
                                           UITextAttributeFont : groupedDetailFont,
                                      UITextAttributeTextColor : textColor,
                                UITextAttributeTextShadowColor : textShadowColor,
                               UITextAttributeTextShadowOffset : textShadowOffset }
                                                       forState:UIControlStateNormal];
        
        [MSGroupedTableViewCell.appearance setTitleTextAttributes:@{
                                                     UITextAttributeFont : groupedTitleFont,
                                                UITextAttributeTextColor : textColor,
                                          UITextAttributeTextShadowColor : textShadowColor,
                                         UITextAttributeTextShadowOffset : textShadowOffset }
                                                                 forState:UIControlStateNormal];
        
        [MSGroupedTableViewCell.appearance setDetailTextAttributes:@{
                                                        UITextAttributeFont : groupedDetailFont,
                                                   UITextAttributeTextColor : textColor,
                                             UITextAttributeTextShadowColor : textShadowColor,
                                            UITextAttributeTextShadowOffset : textShadowOffset }
                                                          forState:UIControlStateNormal];
        
        [MSGroupedTableViewCell.appearance setAccessoryTextAttributes:@{
                                              UITextAttributeFont : groupedAccessoryFont,
                                         UITextAttributeTextColor : textColor,
                                   UITextAttributeTextShadowColor : textShadowColor,
                                  UITextAttributeTextShadowOffset : textShadowOffset }
                                                          forState:UIControlStateNormal];
        
        // Header View
        UIFont *plainHeaderTitleTextFont = [self detailFontOfSize:15.0];
        UIFont *plainHeaderDetailTextFont = [self detailFontOfSize:15.0];
        UIColor *plainHeaderDetailTextColor = [UIColor lightGrayColor];
        NSValue *plainHeaderTextShadowOffset = [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)];
        
        [MSPlainTableViewHeaderView.appearance setTitleTextAttributes:@{
                                                 UITextAttributeFont : plainHeaderTitleTextFont,
                                            UITextAttributeTextColor : plainHeaderDetailTextColor,
                                      UITextAttributeTextShadowColor : textShadowColor,
                                     UITextAttributeTextShadowOffset : plainHeaderTextShadowOffset }];
        
        [MSPlainTableViewHeaderView.appearance setDetailTextAttributes:@{
                                                  UITextAttributeFont : plainHeaderDetailTextFont,
                                             UITextAttributeTextColor : plainHeaderDetailTextColor,
                                       UITextAttributeTextShadowColor : textShadowColor,
                                      UITextAttributeTextShadowOffset : plainHeaderTextShadowOffset }];
        
        [MSPlainTableViewHeaderView.appearance setPadding:UIEdgeInsetsMake(2.0, 10.0, 0.0, 10.0)];
        
        UIFont *groupedHeaderTitleFont = [self titleFontOfSize:19.0];
        UIColor *groupedHeaderTextColor = [UIColor colorWithHexString:@"aaaaaa"];
        NSDictionary *headerFooterTextAttributes = @{
            UITextAttributeFont : groupedHeaderTitleFont,
            UITextAttributeTextColor : groupedHeaderTextColor,
            UITextAttributeTextShadowColor : [UIColor blackColor],
            UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0, -1.0)],
        };
        
        [MSGroupedTableViewHeaderView.appearance setPadding:UIEdgeInsetsMake(15.0, 20.0, 0.0, 20.0)];
        [MSGroupedTableViewHeaderView.appearance setTitleTextAttributes:headerFooterTextAttributes];

        
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
    return [UIColor colorWithHexString:@"404040"];
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
    return [UIFont fontWithName:@"FuturaCom-Medium" size:size];
}

#pragma mark - Images

- (UIImage *)heroPlaceholderImage
{
    return [UIImage imageNamed:@"SFSplashBackground.jpg"];
}

#pragma mark - UICollectionView

- (void)styleCollectionView:(UICollectionView *)collectionView
{
    collectionView.backgroundColor = [self viewBackgroundColor];
    collectionView.backgroundView = nil;
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)stylePopoverCollectionView:(UICollectionView *)collectionView
{
    [self styleCollectionView:collectionView];
    collectionView.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
    collectionView.layer.borderWidth = 1.0;
    collectionView.layer.cornerRadius = 5.0;
}

#pragma mark -  UIButton

- (UIButton *)styledDisclosureButton
{
    UIButton* disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    UIImage *disclosureIcon = [UIImage imageNamed:@"SFDisclosureButtonBackground"];
    UIImage *disclosureIconPressed = [UIImage imageNamed:@"SFDisclosureButtonPressedBackground"];
    [disclosureButton setImage:disclosureIcon forState:UIControlStateNormal];
    [disclosureButton setImage:disclosureIconPressed forState:UIControlStateHighlighted];
    disclosureButton.frame = (CGRect){CGPointZero, disclosureIcon.size};
    return disclosureButton;
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
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 28.0 : 24.0);
    button.titleLabel.font = [self symbolSetFontOfSize:fontSize];
    button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 11.0, 0.0, 11.0);
    [button sizeToFit];
}

- (void)styleBackBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title
{
    [self styleBackBarButtonItemCustomView:button withTitle:title];
    CGFloat fontSize = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 30.0 : 24.0);
    button.titleLabel.font = [self symbolSetFontOfSize:fontSize];
    button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 11.0, 0.0, 11.0);
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

#pragma mark - SVSegmentedControl

- (SVSegmentedControl *)styledSegmentedControlWithTitles:(NSArray *)titles action:(void(^)(NSUInteger newIndex))handler
{
    SVSegmentedControl *segmentedControl = [[SVSegmentedControl alloc] initWithSectionTitles:titles];
    segmentedControl.changeHandler = handler;
    segmentedControl.font = [self titleFontOfSize:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 18.0 : 15.0)];
    segmentedControl.titleEdgeInsets = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIEdgeInsetsMake(2.0, 20.0, 0.0, 20.0) : UIEdgeInsetsMake(2.0, 10.0, 0.0, 10.0));
    segmentedControl.height = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.0 : 32.0);
    segmentedControl.thumb.tintColor = [UIColor colorWithHexString:@"505050"];
    return segmentedControl;
}

#pragma mark - Activity Indicator

- (UIBarButtonItem *)activityIndicatorBarButtonItem
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.layer.shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.8] CGColor];
    activityIndicator.layer.shadowOffset = CGSizeMake(0.0, -1.0);
    activityIndicator.layer.shadowRadius = 0.0;
    activityIndicator.layer.shadowOpacity = 1.0;
    activityIndicator.frame = CGRectMake(0.0, 0.0, 42.0, 30.0);
    [activityIndicator startAnimating];
    return [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
}

@end

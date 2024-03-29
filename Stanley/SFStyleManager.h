//
//  SFStyleManager.h
//  Stanley
//
//  Created by Eric Horacek on 2/11/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

@interface SFStyleManager : NSObject

+ (instancetype)sharedManager;

// Colors
- (UIColor *)viewBackgroundColor;
- (UIColor *)secondaryViewBackgroundColor;
- (UIColor *)primaryTextColor;
- (UIColor *)secondaryTextColor;

// Fonts
- (UIFont *)symbolSetFontOfSize:(CGFloat)size;
- (UIFont *)navigationFontOfSize:(CGFloat)size;
- (UIFont *)titleFontOfSize:(CGFloat)size;
- (UIFont *)titleFontOfSize:(CGFloat)size condensed:(BOOL)condensed oblique:(BOOL)oblique;
- (UIFont *)detailFontOfSize:(CGFloat)size;
- (UIFont *)detailFontOfSize:(CGFloat)size condensed:(BOOL)condensed oblique:(BOOL)oblique;

// Images
- (UIImage *)heroPlaceholderImage;

// UICollectionView
- (void)styleCollectionView:(UICollectionView *)collectionView;
- (void)stylePopoverCollectionView:(UICollectionView *)collectionView;

// UIButton
- (UIButton *)styledDisclosureButton;

// UILabel
- (void)styleDetailLabel:(UILabel *)label autolayout:(BOOL)autolayout;
- (void)styleDetailIconLabel:(UILabel *)label autolayout:(BOOL)autolayout;

// UIBarButtonItem Custom Views
- (void)styleBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title;
- (void)styleBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title fontSize:(CGFloat)fontSize;
- (void)styleBarButtonItemCustomView:(UIButton *)button withImage:(UIImage *)image;

// UIBarButtonItem
- (UIBarButtonItem *)styledBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBarButtonItemWithSymbolsetTitle:(NSString *)title fontSize:(CGFloat)fontSize action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBarButtonItemWithImage:(UIImage *)image action:(void(^)(void))handler;
// Preconfigured
- (UIBarButtonItem *)styledBackBarButtonItemWithAction:(void(^)(void))handler;
- (UIBarButtonItem *)styledCloseBarButtonItemWithAction:(void(^)(void))handler;
- (UIBarButtonItem *)styledFavoriteBarButtonItemWithAction:(void(^)(void))handler;
- (UIBarButtonItem *)styledLogoBarButtonItemWithAction:(void(^)(void))handler;

// SVSegmentedControl
- (SVSegmentedControl *)styledSegmentedControlWithTitles:(NSArray *)titles action:(void(^)(NSUInteger newIndex))handler;

// Activity Indicator
- (UIBarButtonItem *)activityIndicatorBarButtonItem;

@end

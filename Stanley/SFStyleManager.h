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
- (UIFont *)detailFontOfSize:(CGFloat)size;

// UICollectionView
- (void)styleCollectionView:(UICollectionView *)collectionView;
- (void)stylePopoverCollectionView:(UICollectionView *)collectionView;

// UIButton
- (UIButton *)styledDisclosureButton;

// UIBarButtonItem Custom Views
- (void)styleBarButtonItemCustomView:(UIButton *)button;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button;
- (void)styleBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title;
- (void)styleBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title;
- (void)styleBarButtonItemCustomView:(UIButton *)button withImage:(UIImage *)image;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button withImage:(UIImage *)image;

// UIBarButtonItem
- (UIBarButtonItem *)styledBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBackBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBarButtonItemWithSymbolsetTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBackBarButtonItemWithSymbolsetTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBarButtonItemWithImage:(UIImage *)image action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBackBarButtonItemWithImage:(UIImage *)image action:(void(^)(void))handler;

// SVSegmentedControl
- (SVSegmentedControl *)styledSegmentedControlWithTitles:(NSArray *)titles action:(void(^)(NSUInteger newIndex))handler;

// Activity Indicator
- (UIBarButtonItem *)activityIndicatorBarButtonItem;

@end

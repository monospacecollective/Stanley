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

// Fonts
- (UIFont *)symbolSetFontOfSize:(CGFloat)size;
- (UIFont *)navigationFontOfSize:(CGFloat)size;
- (UIFont *)titleFontOfSize:(CGFloat)size;
- (UIFont *)subtitleFontOfSize:(CGFloat)size;

// UICollectionView
- (void)styleCollectionView:(PSUICollectionView *)collectionView;

// UIBarButtonItem Custom Views
- (void)styleBarButtonItemCustomView:(UIButton *)button;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button;
- (void)styleBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button withTitle:(NSString *)title;
- (void)styleBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title;
- (void)styleBackBarButtonItemCustomView:(UIButton *)button withSymbolsetTitle:(NSString *)title;

// UIBarButtonItem
- (UIBarButtonItem *)styledBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBackBarButtonItemWithTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBarButtonItemWithSymbolsetTitle:(NSString *)title action:(void(^)(void))handler;
- (UIBarButtonItem *)styledBackBarButtonItemWithSymbolsetTitle:(NSString *)title action:(void(^)(void))handler;

@end

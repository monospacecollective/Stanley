//
//  SFFilmCell.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFFilm;

@interface SFFilmCell : UICollectionViewCell

@property (nonatomic, weak) SFFilm *film;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIImageView *favoriteIndicator;
@property (nonatomic, strong) FXLabel *placeholderIcon;

+ (CGSize)cellSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGFloat)cellSpacingForInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (UIEdgeInsets)cellMarginForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

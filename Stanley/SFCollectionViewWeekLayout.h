//
//  SFCollectionViewWeekLayout.h
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

// Headers
extern NSString *const SFCollectionElementKindTimeRowHeader;
extern NSString *const SFCollectionElementKindDayColumnHeader;
extern NSString *const SFCollectionElementKindTimeRowHeaderBackground;
extern NSString *const SFCollectionElementKindDayColumnHeaderBackground;

// Current Time Indicator
extern NSString *const SFCollectionElementKindCurrentTimeIndicator;

// Gridlines
extern NSString *const SFCollectionElementKindHorizontalGridline;
extern NSString *const SFCollectionElementKindCurrentTimeHorizontalGridline;

typedef NS_ENUM(NSUInteger, SFWeekLayoutSectionLayoutType) {
    SFWeekLayoutSectionLayoutTypeHorizontalTile,
    SFWeekLayoutSectionLayoutTypeVerticalTile
};

@class SFCollectionViewWeekLayout;

@protocol SFCollectionViewDelegateWeekLayout <UICollectionViewDelegate>

@required

- (NSDate *)collectionView:(PSUICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout dayForSection:(NSInteger)section;
- (NSDate *)collectionView:(PSUICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)collectionView:(PSUICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)currentTimeComponentsForCollectionView:(PSUICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout;

@end

@interface SFCollectionViewWeekLayout : PSUICollectionViewLayout

@property (nonatomic, weak) id <SFCollectionViewDelegateWeekLayout> delegate;

@property (nonatomic, assign) CGFloat sectionWidth;
@property (nonatomic, assign) CGFloat hourHeight;
@property (nonatomic, assign) CGFloat dayColumnHeaderReferenceHeight;
@property (nonatomic, assign) CGFloat timeRowHeaderReferenceWidth;
@property (nonatomic, assign) CGSize currentTimeIndicatorReferenceSize;
@property (nonatomic, assign) CGFloat horizontalGridlineReferenceHeight;
@property (nonatomic, assign) CGFloat currentTimeHorizontalGridlineReferenceHeight;
@property (nonatomic, assign) UIEdgeInsets sectionMargin;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) SFWeekLayoutSectionLayoutType sectionLayoutType;

- (NSDate *)dateForTimeRowHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollCollectionViewToClosetSectionToCurrentTimeAnimated:(BOOL)animated;
- (NSInteger)closestSectionToCurrentTime;

@end

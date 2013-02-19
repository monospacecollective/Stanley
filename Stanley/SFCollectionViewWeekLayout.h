//
//  SFCollectionViewWeekLayout.h
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SFCollectionElementKindTimeRowHeader;
extern NSString *const SFCollectionElementKindDayColumnHeader;
extern NSString *const SFCollectionElementKindCurrentTimeIndicator;

@class SFCollectionViewWeekLayout;

@protocol SFCollectionViewDelegateWeekLayout <UICollectionViewDelegate>

@required

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout dayForSection:(NSInteger)section;
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(SFCollectionViewWeekLayout *)collectionViewLayout;

@end

@interface SFCollectionViewWeekLayout : UICollectionViewLayout

@property (nonatomic, weak) id <SFCollectionViewDelegateWeekLayout> delegate;

@property (nonatomic, assign) CGFloat sectionWidth;
@property (nonatomic, assign) CGFloat hourHeight;
@property (nonatomic, assign) CGFloat dayColumnHeaderReferenceHeight;
@property (nonatomic, assign) CGFloat timeRowHeaderReferenceWidth;
@property (nonatomic, assign) CGSize currentTimeIndicatorReferenceSize;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

- (NSDate *)dateForTimeRowHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath;

@end

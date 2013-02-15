//
//  SFCollectionViewStickyHeaderFlowLayout.m
//  Stanley
//
//  Created by Eric Horacek on 2/14/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFCollectionViewStickyHeaderFlowLayout.h"

@implementation SFCollectionViewStickyHeaderFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *headerAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    for (PSUICollectionViewLayoutAttributes *layoutAttributes in headerAttributes) {
        if (layoutAttributes.representedElementCategory == PSTCollectionViewItemTypeCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }
    for (PSUICollectionViewLayoutAttributes *layoutAttributes in headerAttributes) {
        if ([layoutAttributes.representedElementKind isEqualToString:PSTCollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
    
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        PSUICollectionViewLayoutAttributes *layoutAttributes = (PSUICollectionViewLayoutAttributes *)[self layoutAttributesForSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader atIndexPath:indexPath];
        [headerAttributes addObject:layoutAttributes];
    }];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in headerAttributes) {
        
        if ([layoutAttributes.representedElementKind isEqualToString:PSTCollectionElementKindSectionHeader]) {
            
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
            
            PSUICollectionViewLayoutAttributes *firstCellAttrs = (PSUICollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            PSUICollectionViewLayoutAttributes *lastCellAttrs = (PSUICollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
            
            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
            CGPoint origin = layoutAttributes.frame.origin;
            origin.y = fminf(fmaxf(self.collectionView.contentOffset.y, (CGRectGetMinY(firstCellAttrs.frame) - headerHeight)), (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight));
            
            layoutAttributes.zIndex = 1;
            layoutAttributes.frame = (CGRect){origin, layoutAttributes.frame.size};
        }
    }
    
    return headerAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{    
    return YES;
}

@end

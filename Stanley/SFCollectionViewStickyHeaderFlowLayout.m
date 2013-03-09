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
    NSMutableArray *rectAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    if (!self.stickySectionHeaders) {
        return rectAttributes;
    }
    
    for (UICollectionViewLayoutAttributes *attributes in rectAttributes) {
        if (attributes.representedElementKind == UICollectionElementKindSectionHeader) {
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:attributes.indexPath.section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:fmaxf(0, ([self.collectionView numberOfItemsInSection:attributes.indexPath.section] - 1)) inSection:attributes.indexPath.section];
            
            UICollectionViewLayoutAttributes *firstCellAttributes = (UICollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            UICollectionViewLayoutAttributes *lastCellAttributes = (UICollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
            
            attributes.zIndex = 1;
            
            CGPoint origin = attributes.frame.origin;
            origin.y = fminf(fmaxf(self.collectionView.contentOffset.y, (CGRectGetMinY(firstCellAttributes.frame) - CGRectGetHeight(attributes.frame))), (CGRectGetMaxY(lastCellAttributes.frame) - CGRectGetHeight(attributes.frame)));
            attributes.frame = (CGRect){origin, attributes.frame.size};
        }
    }
    return rectAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return self.stickySectionHeaders;
}

@end

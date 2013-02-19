//
//  SFCollectionViewWeekLayout.m
//  Stanley
//
//  Created by Eric Horacek on 2/18/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFCollectionViewWeekLayout.h"

NSString *const SFCollectionElementKindTimeRowHeader = @"SFCollectionElementKindTimeRow";
NSString *const SFCollectionElementKindDayColumnHeader = @"SFCollectionElementKindDayHeader";
NSString *const SFCollectionElementKindCurrentTimeIndicator = @"SFCollectionElementKindCurrentTimeIndicator";

CGFloat const SFCollectionElementKindCurrentTimeIndicatorIndexZ = 3.0;
CGFloat const SFCollectionElementKindTimeRowHeaderIndexZ = 2.0;
CGFloat const SFCollectionElementKindDayColumnHeaderIndexZ = 1.0;

@interface SFCollectionViewWeekLayout ()

// Caches
@property (nonatomic, strong) NSMutableArray *columnHeights;
@property (nonatomic, assign) CGFloat maxColumnHeight;
@property (nonatomic, readonly) CGFloat minuteHeight;

@property (nonatomic, strong) NSMutableDictionary *itemAttributes;
@property (nonatomic, strong) NSMutableArray *dayColumnHeaderAttributes;
@property (nonatomic, strong) NSMutableArray *timeRowHeaderAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *currentTimeIndicatorAttributes;

@end

@implementation SFCollectionViewWeekLayout

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        
        self.columnHeights = [NSMutableArray new];
        self.maxColumnHeight = CGFLOAT_MAX;
        
        self.itemAttributes = [NSMutableDictionary new];
        self.dayColumnHeaderAttributes = [NSMutableArray new];
        self.timeRowHeaderAttributes = [NSMutableArray new];
        
        self.hourHeight = 60.0;
        self.sectionWidth = 235.0;
        self.dayColumnHeaderReferenceHeight = 44.0;
        self.timeRowHeaderReferenceWidth = 80.0;
        self.currentTimeIndicatorReferenceSize = CGSizeMake(40.0, 30.0);
        self.sectionInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    }
    return self;
}

#pragma mark - UICollectionViewLayout

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    // Flush all caches
    [self.columnHeights removeAllObjects];
    
    self.maxColumnHeight = CGFLOAT_MAX;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.itemAttributes removeAllObjects];
    
    NSInteger earliestHour = [self earliestHour];
    NSInteger latestHour = [self latestHour];
    
    // Current Time Indicator
    self.currentTimeIndicatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator withIndexPath:nil];
    NSDateComponents *dateComponents = [self currentTimeDateComponents];
    if ((dateComponents.hour > earliestHour) && (dateComponents.hour < latestHour)) {
        CGFloat currentTimeIndicatorMinY = nearbyintf(((dateComponents.hour - earliestHour) * self.hourHeight) + (dateComponents.minute * self.minuteHeight)) - nearbyintf(self.timeRowHeaderReferenceWidth / 2.0);
        CGFloat currentTimeIndicatorMinX = (fmaxf(self.collectionView.contentOffset.x, 0.0) + (self.timeRowHeaderReferenceWidth - self.currentTimeIndicatorReferenceSize.width));
        self.currentTimeIndicatorAttributes.frame = (CGRect){{currentTimeIndicatorMinX, currentTimeIndicatorMinY}, self.currentTimeIndicatorReferenceSize};
        self.currentTimeIndicatorAttributes.zIndex = SFCollectionElementKindCurrentTimeIndicatorIndexZ;
    } else {
        self.currentTimeIndicatorAttributes.frame = CGRectZero;
    }
    
    // Time Row Header
    NSUInteger timeRowHeaderIndex = 0;
    for (NSInteger hour = earliestHour; hour <= (latestHour - 1); hour++) {
        UICollectionViewLayoutAttributes *timeRowHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withIndexPath:[NSIndexPath indexPathForItem:timeRowHeaderIndex inSection:0]];
        CGFloat titleRowHeaderMinY = (self.dayColumnHeaderReferenceHeight + (self.hourHeight * hour) - nearbyintf(self.hourHeight / 2.0));
        CGFloat titleRowHeaderMinX = fmaxf(self.collectionView.contentOffset.x, 0.0);
        timeRowHeaderAttributes.frame = CGRectMake(titleRowHeaderMinX, titleRowHeaderMinY, self.timeRowHeaderReferenceWidth, self.hourHeight);
        timeRowHeaderAttributes.zIndex = SFCollectionElementKindTimeRowHeaderIndexZ;
        self.timeRowHeaderAttributes[timeRowHeaderIndex] = timeRowHeaderAttributes;
        timeRowHeaderIndex++;
    }
    
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        
        // Day Column Header
        UICollectionViewLayoutAttributes *dayColumnHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        CGFloat dayColumnMinX = (self.sectionWidth * section) + self.timeRowHeaderReferenceWidth;
        dayColumnHeaderAttributes.frame = CGRectMake(dayColumnMinX, fmaxf(self.collectionView.contentOffset.y, 0.0), self.sectionWidth, self.dayColumnHeaderReferenceHeight);
        dayColumnHeaderAttributes.zIndex = SFCollectionElementKindDayColumnHeaderIndexZ;
        self.dayColumnHeaderAttributes[section] = dayColumnHeaderAttributes;
        
        // Cells
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            // Frame Calculation
            NSDateComponents *startTime = [self startTimeForIndexPath:indexPath];
            NSDateComponents *endTime = [self endTimeForIndexPath:indexPath];
            CGFloat itemMinY = (((startTime.hour - earliestHour) * self.hourHeight) + (startTime.minute * self.minuteHeight) + self.dayColumnHeaderReferenceHeight + self.sectionInset.top);
            CGFloat itemMaxY = (((endTime.hour - earliestHour) * self.hourHeight) + (endTime.minute * self.minuteHeight) + self.dayColumnHeaderReferenceHeight - self.sectionInset.bottom);
            
            CGFloat itemMinX = ((self.sectionWidth * section) + self.timeRowHeaderReferenceWidth + self.sectionInset.left);
            CGFloat itemMaxX = (itemMinX + self.sectionWidth) - self.sectionInset.left - self.sectionInset.right;
            
            itemAttributes.frame = CGRectMake(itemMinX, itemMinY, (itemMaxX - itemMinX), (itemMaxY - itemMinY));
            
            self.itemAttributes[indexPath] = itemAttributes;
        }
    }
}

- (CGSize)collectionViewContentSize
{
    CGFloat width = (self.timeRowHeaderReferenceWidth + (self.sectionWidth * self.collectionView.numberOfSections));
    CGFloat height = [self maxColumnHeight];
    return CGSizeMake(width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemAttributes[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
        return self.dayColumnHeaderAttributes[indexPath.section];
    }
    else if ([kind isEqualToString:SFCollectionElementKindTimeRowHeader]) {
        return self.timeRowHeaderAttributes[indexPath.row];
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([decorationViewKind isEqualToString:SFCollectionElementKindCurrentTimeIndicator]) {
        return self.currentTimeIndicatorAttributes;
    }
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableSet *allItems = [NSMutableSet new];
    
    [allItems addObjectsFromArray:self.itemAttributes.allValues];
    [allItems addObjectsFromArray:self.dayColumnHeaderAttributes];
    [allItems addObjectsFromArray:self.timeRowHeaderAttributes];
    [allItems addObject:self.currentTimeIndicatorAttributes];
    
    return [[allItems allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, layoutAttributes.frame);
    }]];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark - SFCollectionViewWeekLayout

- (NSDate *)dateForTimeRowHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger earliestHour = [self earliestHour];
    NSDateComponents *dateComponents = [self dayForSection:indexPath.section];
    dateComponents.hour = (earliestHour + indexPath.row);
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.delegate collectionView:self.collectionView layout:self dayForSection:indexPath.section] beginningOfDay];
}

#pragma mark Column Heights

- (CGFloat)maxColumnHeight
{
    CGFloat maxColumnHeight = 0.0;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        CGFloat sectionColumnHeight = [self columnHeightForSection:section];
        if (sectionColumnHeight > maxColumnHeight) {
            maxColumnHeight = sectionColumnHeight;
        }
    }
    maxColumnHeight += self.dayColumnHeaderReferenceHeight;
    return maxColumnHeight;
}

- (CGFloat)columnHeightForSection:(NSInteger)section
{
    NSInteger earliestHour = [self earliestHour];
    NSInteger latestHour = [self latestHourForSection:section];
    
    if ((earliestHour != NSUndefinedDateComponent) && (latestHour != NSUndefinedDateComponent)) {
        return (self.hourHeight * (latestHour - earliestHour));
    } else {
        return 0.0;
    }
}

- (CGFloat)minuteHeight
{
    return (self.hourHeight / 60.0);
}

#pragma mark Hours

- (NSInteger)earliestHour
{
    NSInteger earliestHour = NSIntegerMax;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        CGFloat sectionEarliestHour = [self earliestHourForSection:section];
        if ((sectionEarliestHour < earliestHour) && (sectionEarliestHour != NSUndefinedDateComponent)) {
            earliestHour = sectionEarliestHour;
        }
    }
    return ((earliestHour != NSIntegerMax) ? earliestHour : 0);
}

- (NSInteger)latestHour
{
    NSInteger latestHour = NSIntegerMin;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        CGFloat sectionLatestHour = [self latestHourForSection:section];
        if ((sectionLatestHour > latestHour) && (sectionLatestHour != NSUndefinedDateComponent)) {
            latestHour = sectionLatestHour;
        }
    }
    return ((latestHour != NSIntegerMin) ? latestHour : 0);
}

- (NSInteger)earliestHourForSection:(NSInteger)section
{
    NSInteger earliestHour = NSIntegerMax;
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        NSDateComponents *itemStartTime = [self startTimeForIndexPath:itemIndexPath];
        if (itemStartTime.hour < earliestHour) {
            earliestHour = itemStartTime.hour;
        }
    }
    return ((earliestHour != NSIntegerMax) ? earliestHour : 0);
}

- (NSInteger)latestHourForSection:(NSInteger)section
{
    NSInteger latestHour = NSIntegerMin;
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        NSDateComponents *itemEndTime = [self endTimeForIndexPath:itemIndexPath];
        NSInteger itemEndTimeHour = (itemEndTime.hour + ((itemEndTime.minute > 0) ? 1 : 0));
        if (itemEndTimeHour > latestHour) {
            latestHour = itemEndTimeHour;
        }
    }
    return ((latestHour != NSIntegerMin) ? latestHour : 0);
}

#pragma mark Delegate Wrappers

- (NSDateComponents *)dayForSection:(NSInteger)section;
{
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self dayForSection:section];
    NSDateComponents *day = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:date];
    
    NSAssert((day.day != NSUndefinedDateComponent), @"The collectionView:layout:dayForSection: date component must contain a 'day' component");
    
    return day;
}

- (NSDateComponents *)startTimeForIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self startTimeForItemAtIndexPath:indexPath];
    NSDateComponents *itemStartTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSAssert((itemStartTime.day != NSUndefinedDateComponent), @"The collectionView:layout:startTimeForItemAtIndexPath: date component must contain a 'day' component");
    NSAssert((itemStartTime.hour != NSUndefinedDateComponent), @"The collectionView:layout:startTimeForItemAtIndexPath: date component must contain a 'hour' component");
    NSAssert((itemStartTime.minute != NSUndefinedDateComponent), @"The collectionView:layout:startTimeForItemAtIndexPath: date component must contain a 'minute' component");
    
    // Ensure the day component of the item is the same as the day component of the item's section
    NSDateComponents *day = [self dayForSection:indexPath.section];
    NSAssert1(day.day == itemStartTime.day, @"The 'day' date component (%i) from collectionView:layout:dayForSection: must match the 'day' component in collectionView:layout:startTimeForItemAtIndexPath:", indexPath.section);
    
    return itemStartTime;
}

- (NSDateComponents *)endTimeForIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPath];
    NSDateComponents *itemEndTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSAssert((itemEndTime.day != NSUndefinedDateComponent), @"The collectionView:layout:endTimeForItemAtIndexPath: date component must contain a 'day' component");
    NSAssert((itemEndTime.hour != NSUndefinedDateComponent), @"The collectionView:layout:endTimeForItemAtIndexPath: date component must contain a 'hour' component");
    NSAssert((itemEndTime.minute != NSUndefinedDateComponent), @"The collectionView:layout:endTimeForItemAtIndexPath: date component must contain a 'minute' component");
    
    // Ensure the day component of the item is the same as the day component of the item's section
    NSDateComponents *day = [self dayForSection:indexPath.section];
    NSAssert1(day.day == itemEndTime.day, @"The 'day' date component (%i) from collectionView:layout:dayForSection: must match the 'day' component in collectionView:layout:endTimeForItemAtIndexPath:", indexPath.section);
    return itemEndTime;
}

- (NSDateComponents *)currentTimeDateComponents
{
    NSDate *date = [self.delegate currentTimeComponentsForCollectionView:self.collectionView layout:self];
    NSDateComponents *currentTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSAssert((currentTime.day != NSUndefinedDateComponent), @"The currentTimeComponentsForCollectionView::layout: date component must contain a 'day' component");
    NSAssert((currentTime.hour != NSUndefinedDateComponent), @"The currentTimeComponentsForCollectionView::layout: date component must contain a 'hour' component");
    NSAssert((currentTime.minute != NSUndefinedDateComponent), @"The currentTimeComponentsForCollectionView::layout: date component must contain a 'minute' component");
    return currentTime;
}

@end

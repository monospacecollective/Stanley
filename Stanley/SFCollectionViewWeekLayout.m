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
NSString *const SFCollectionElementHorizontalGridline = @"SFCollectionElementHorizontalGridline";
NSString *const SFCollectionElementCurrentTimeHorizontalGridline = @"SFCollectionElementCurrentTimeHorizontalGridline";
NSString *const SFCollectionElementKindTimeRowHeaderBackground = @"SFCollectionElementKindTimeRowHeaderBackground";
NSString *const SFCollectionElementKindDayColumnHeaderBackground = @"SFCollectionElementKindDayColumnHeaderBackground";

CGFloat const SFCollectionElementKindIndexZCurrentTimeIndicator = 11.0;

// Floating headers
CGFloat const SFCollectionElementKindIndexZTimeRowHeaderFloating = 10.0;
CGFloat const SFCollectionElementKindIndexZTimeRowHeaderBackgroundFloating = 9.0;
CGFloat const SFCollectionElementKindIndexZDayColumnHeaderFloating = 8.0;
CGFloat const SFCollectionElementKindIndexZDayColumnHeaderBackgroundFloating = 7.0;

// Headers
CGFloat const SFCollectionElementKindIndexZTimeRowHeader = 6.0;
CGFloat const SFCollectionElementKindIndexZTimeRowHeaderBackground = 5.0;
CGFloat const SFCollectionElementKindIndexZDayColumnHeader = 4.0;
CGFloat const SFCollectionElementKindIndexZDayColumnHeaderBackground = 3.0;

CGFloat const SFCollectionCellIndexZ = 2.0;

CGFloat const SFCollectionElementKindIndexZCurrentTimeHorizontalGridline = 1.0;
CGFloat const SFCollectionElementKindIndexZHorizontalGridline = 0.0;

@interface SFCollectionViewWeekLayout ()

// Caches
@property (nonatomic, assign) CGFloat cachedMaxColumnHeight;
@property (nonatomic, assign) NSInteger cachedEarliestHour;
@property (nonatomic, assign) NSInteger cachedLatestHour;

// Contains the attributes for all items
@property (nonatomic, strong) NSMutableArray *allAttributes;

// Cell Attributes
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;

// Header Attributes (Row/Col)
@property (nonatomic, strong) NSMutableArray *dayColumnHeaderAttributes;
@property (nonatomic, strong) NSMutableArray *timeRowHeaderAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *currentTimeIndicatorAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *dayColumnHeaderBackgroundAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *timeRowHeaderBackgroundAttributes;


// Gridlines
@property (nonatomic, strong) NSMutableArray *horizontalGridlineAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *currentTimeHorizontalGridlineAttributes;

@property (nonatomic, readonly) CGFloat minuteHeight;

@end

@implementation SFCollectionViewWeekLayout

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (self) {
        
        self.cachedMaxColumnHeight = CGFLOAT_MIN;
        self.cachedEarliestHour = NSIntegerMax;
        self.cachedLatestHour = NSIntegerMin;
        
        self.allAttributes = [NSMutableArray new];
        self.itemAttributes = [NSMutableDictionary new];
        self.dayColumnHeaderAttributes = [NSMutableArray new];
        self.timeRowHeaderAttributes = [NSMutableArray new];
        self.horizontalGridlineAttributes = [NSMutableArray new];
        
        self.hourHeight = 60.0;
        self.sectionWidth = 236.0;
        self.dayColumnHeaderReferenceHeight = 60.0;
        self.timeRowHeaderReferenceWidth = 80.0;
        self.currentTimeIndicatorReferenceSize = CGSizeMake(86.0, 40.0);
        self.sectionInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
        self.currentTimeHorizontalGridlineReferenceHeight = 9.0;
        self.horizontalGridlineReferenceHeight = 2.0;
    }
    return self;
}

#pragma mark - UICollectionViewLayout

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    // Invalidate cached values
    self.cachedEarliestHour = NSIntegerMax;
    self.cachedLatestHour = NSIntegerMin;
    self.cachedMaxColumnHeight = CGFLOAT_MIN;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.allAttributes removeAllObjects];
    [self.itemAttributes removeAllObjects];
    [self.dayColumnHeaderAttributes removeAllObjects];
    [self.timeRowHeaderAttributes removeAllObjects];
    [self.horizontalGridlineAttributes removeAllObjects];
    
    NSInteger earliestHour = [self earliestHour];
    NSInteger latestHour = [self latestHour];
    
    // Current Time Indicator
    self.currentTimeIndicatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator withIndexPath:nil];
    [self.allAttributes addObject:self.currentTimeIndicatorAttributes];
    self.currentTimeHorizontalGridlineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementCurrentTimeHorizontalGridline withIndexPath:nil];
    [self.allAttributes addObject:self.currentTimeHorizontalGridlineAttributes];
    
    // The current time is within the day
    NSDateComponents *currentTimeDateComponents = [self currentTimeDateComponents];
    if ((currentTimeDateComponents.hour > earliestHour) && (currentTimeDateComponents.hour < latestHour)) {
        // The y value of the current time
        CGFloat timeY = (self.dayColumnHeaderReferenceHeight + nearbyintf(((currentTimeDateComponents.hour - earliestHour) * self.hourHeight) + (currentTimeDateComponents.minute * self.minuteHeight)));
        
        CGFloat currentTimeIndicatorMinY = (timeY - nearbyintf(self.currentTimeIndicatorReferenceSize.height / 2.0));
        CGFloat currentTimeIndicatorMinX = (fmaxf(self.collectionView.contentOffset.x, 0.0) + (self.timeRowHeaderReferenceWidth - self.currentTimeIndicatorReferenceSize.width));
        self.currentTimeIndicatorAttributes.frame = (CGRect){{currentTimeIndicatorMinX, currentTimeIndicatorMinY}, self.currentTimeIndicatorReferenceSize};
        self.currentTimeIndicatorAttributes.zIndex = SFCollectionElementKindIndexZCurrentTimeIndicator;
        
        CGFloat currentTimeHorizontalGridlineMinY = (timeY - nearbyintf(self.currentTimeHorizontalGridlineReferenceHeight / 2.0));
        CGFloat currentTimeHorizontalGridlineWidth = (self.collectionViewContentSize.width - self.timeRowHeaderReferenceWidth);
        self.currentTimeHorizontalGridlineAttributes.frame = CGRectMake(self.timeRowHeaderReferenceWidth, currentTimeHorizontalGridlineMinY, currentTimeHorizontalGridlineWidth, self.currentTimeHorizontalGridlineReferenceHeight);
        self.currentTimeHorizontalGridlineAttributes.zIndex = SFCollectionElementKindIndexZCurrentTimeHorizontalGridline;
        
    } else {
        self.currentTimeIndicatorAttributes.frame = CGRectZero;
        self.currentTimeHorizontalGridlineAttributes.frame = CGRectZero;
    }
    
    // Time Row Header Background
    CGFloat timeRowHeaderMinX = fmaxf(self.collectionView.contentOffset.x, 0.0);
    CGFloat timeRowHeaderMinY = -nearbyintf(self.collectionView.frame.size.height / 2.0);
    CGFloat timeRowHeaderBackgroundHeight = fmaxf(self.collectionViewContentSize.height + self.collectionView.frame.size.height, self.collectionView.frame.size.height);
    self.timeRowHeaderBackgroundAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindTimeRowHeaderBackground withIndexPath:nil];
    self.timeRowHeaderBackgroundAttributes.frame = CGRectMake(timeRowHeaderMinX, timeRowHeaderMinY, self.timeRowHeaderReferenceWidth, timeRowHeaderBackgroundHeight);
    // Floating
    BOOL timeRowHeaderBackgroundFloating = (timeRowHeaderMinX != 0);
    self.timeRowHeaderBackgroundAttributes.hidden = !timeRowHeaderBackgroundFloating;
    self.timeRowHeaderBackgroundAttributes.zIndex = (timeRowHeaderBackgroundFloating ? SFCollectionElementKindIndexZTimeRowHeaderBackgroundFloating : SFCollectionElementKindIndexZTimeRowHeaderBackground);
    [self.allAttributes addObject:self.timeRowHeaderBackgroundAttributes];
    
    // Day Column Header Background
    CGFloat dayColumnHeaderMinY = fmaxf(self.collectionView.contentOffset.y, 0.0);
    CGFloat dayColumnHeaderMinX = -nearbyintf(self.collectionView.frame.size.width / 2.0);
    CGFloat dayColumnHeaderBackgroundWidth = fmaxf(self.collectionViewContentSize.width + self.collectionView.frame.size.width, self.collectionView.frame.size.width);
    self.dayColumnHeaderBackgroundAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindDayColumnHeaderBackground withIndexPath:nil];
    self.dayColumnHeaderBackgroundAttributes.frame = CGRectMake(dayColumnHeaderMinX, dayColumnHeaderMinY, dayColumnHeaderBackgroundWidth, self.dayColumnHeaderReferenceHeight);
    // Floating
    BOOL dayColumnHeaderBackgroundFloating = (dayColumnHeaderMinY != 0);
    self.dayColumnHeaderBackgroundAttributes.hidden = !dayColumnHeaderBackgroundFloating;
    self.dayColumnHeaderBackgroundAttributes.zIndex = (dayColumnHeaderBackgroundFloating ? SFCollectionElementKindIndexZDayColumnHeaderBackgroundFloating : SFCollectionElementKindIndexZDayColumnHeaderBackground);
    [self.allAttributes addObject:self.dayColumnHeaderBackgroundAttributes];
    
    // Time Row Headers
    NSUInteger timeRowHeaderIndex = 0;
    for (NSInteger hour = earliestHour; hour <= latestHour; hour++) {
        UICollectionViewLayoutAttributes *timeRowHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withIndexPath:[NSIndexPath indexPathForItem:timeRowHeaderIndex inSection:0]];
        CGFloat titleRowHeaderMinY = (self.dayColumnHeaderReferenceHeight + (self.hourHeight * (hour - earliestHour)) - nearbyintf(self.hourHeight / 2.0));
        timeRowHeaderAttributes.frame = CGRectMake(timeRowHeaderMinX, titleRowHeaderMinY, self.timeRowHeaderReferenceWidth, self.hourHeight);
        timeRowHeaderAttributes.zIndex = (timeRowHeaderBackgroundFloating ? SFCollectionElementKindIndexZTimeRowHeaderFloating : SFCollectionElementKindIndexZTimeRowHeader);
        self.timeRowHeaderAttributes[timeRowHeaderIndex] = timeRowHeaderAttributes;
        [self.allAttributes addObject:timeRowHeaderAttributes];
        timeRowHeaderIndex++;
    }
    
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        
        // Day Column Header
        UICollectionViewLayoutAttributes *dayColumnHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        CGFloat dayColumnMinX = (self.sectionWidth * section) + self.timeRowHeaderReferenceWidth;
        dayColumnHeaderAttributes.frame = CGRectMake(dayColumnMinX, dayColumnHeaderMinY, self.sectionWidth, self.dayColumnHeaderReferenceHeight);
        dayColumnHeaderAttributes.zIndex = (dayColumnHeaderBackgroundFloating ? SFCollectionElementKindIndexZDayColumnHeaderFloating : SFCollectionElementKindIndexZDayColumnHeader);;
        self.dayColumnHeaderAttributes[section] = dayColumnHeaderAttributes;
        [self.allAttributes addObject:dayColumnHeaderAttributes];
        
        for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.zIndex = SFCollectionCellIndexZ;
            
            // Frame Calculation
            NSDateComponents *startTime = [self startTimeForIndexPath:indexPath];
            NSDateComponents *endTime = [self endTimeForIndexPath:indexPath];
            CGFloat itemMinY = (((startTime.hour - earliestHour) * self.hourHeight) + (startTime.minute * self.minuteHeight) + self.dayColumnHeaderReferenceHeight + self.sectionInset.top);
            CGFloat itemMaxY = (((endTime.hour - earliestHour) * self.hourHeight) + (endTime.minute * self.minuteHeight) + self.dayColumnHeaderReferenceHeight - self.sectionInset.bottom);
            
            CGFloat itemMinX = ((self.sectionWidth * section) + self.timeRowHeaderReferenceWidth + self.sectionInset.left);
            CGFloat itemMaxX = (itemMinX + self.sectionWidth) - self.sectionInset.left - self.sectionInset.right;
            
            itemAttributes.frame = CGRectMake(itemMinX, itemMinY, (itemMaxX - itemMinX), (itemMaxY - itemMinY));
            
            self.itemAttributes[indexPath] = itemAttributes;
            [self.allAttributes addObject:itemAttributes];
        }
    }
    
    // Horizontal Gridlines
    NSUInteger horizontalGridlineIndex = 0;
    for (NSInteger hour = earliestHour; hour <= latestHour; hour++) {
        UICollectionViewLayoutAttributes *horizontalGridlineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementHorizontalGridline withIndexPath:[NSIndexPath indexPathForItem:horizontalGridlineIndex inSection:0]];
        CGFloat titleRowHeaderMinY = (self.dayColumnHeaderReferenceHeight + (self.hourHeight * (hour - earliestHour))) - nearbyintf(self.horizontalGridlineReferenceHeight / 2.0);
        CGFloat titleRowHeaderWidth = (self.collectionViewContentSize.width - self.timeRowHeaderReferenceWidth);
        horizontalGridlineAttributes.frame = CGRectMake(self.timeRowHeaderReferenceWidth, titleRowHeaderMinY, titleRowHeaderWidth, self.horizontalGridlineReferenceHeight);
        self.horizontalGridlineAttributes[horizontalGridlineIndex] = horizontalGridlineAttributes;
        [self.allAttributes addObject:horizontalGridlineAttributes];
        horizontalGridlineIndex++;
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
    else if ([decorationViewKind isEqualToString:SFCollectionElementHorizontalGridline]) {
        return self.horizontalGridlineAttributes[indexPath.row];
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementCurrentTimeHorizontalGridline]) {
        return self.currentTimeHorizontalGridlineAttributes;
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementKindTimeRowHeaderBackground]) {
        return self.timeRowHeaderBackgroundAttributes;
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
        return self.dayColumnHeaderBackgroundAttributes;
    }
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.allAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
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
    if (self.cachedMaxColumnHeight != CGFLOAT_MIN) {
        return self.cachedMaxColumnHeight;
    }
    CGFloat maxColumnHeight = 0.0;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        CGFloat sectionColumnHeight = [self columnHeightForSection:section];
        if (sectionColumnHeight > maxColumnHeight) {
            maxColumnHeight = sectionColumnHeight;
        }
    }
    CGFloat headerAdjustedMaxColumnHeight = (maxColumnHeight + self.dayColumnHeaderReferenceHeight + self.hourHeight);
    if (maxColumnHeight != 0.0) {
        self.cachedMaxColumnHeight = headerAdjustedMaxColumnHeight;
        return headerAdjustedMaxColumnHeight;
    } else {
        return headerAdjustedMaxColumnHeight;
    }
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
    if (self.cachedEarliestHour != NSIntegerMax) {
        return self.cachedEarliestHour;
    }
    NSInteger earliestHour = NSIntegerMax;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        CGFloat sectionEarliestHour = [self earliestHourForSection:section];
        if ((sectionEarliestHour < earliestHour) && (sectionEarliestHour != NSUndefinedDateComponent)) {
            earliestHour = sectionEarliestHour;
        }
    }
    if (earliestHour != NSIntegerMax) {
        self.cachedEarliestHour = earliestHour;
        return earliestHour;
    } else {
        return 0;
    }
}

- (NSInteger)latestHour
{
    if (self.cachedLatestHour != NSIntegerMin) {
        return self.cachedLatestHour;
    }
    NSInteger latestHour = NSIntegerMin;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        CGFloat sectionLatestHour = [self latestHourForSection:section];
        if ((sectionLatestHour > latestHour) && (sectionLatestHour != NSUndefinedDateComponent)) {
            latestHour = sectionLatestHour;
        }
    }
    if (latestHour != NSIntegerMin) {
        self.cachedLatestHour = latestHour;
        return latestHour;
    } else {
        return 0;
    }
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
    
    // Ensure the day component of the item is the same as the day component of the item's section
    NSDateComponents *day = [self dayForSection:indexPath.section];
    NSAssert1(day.day == itemStartTime.day, @"The 'day' date component (%i) from collectionView:layout:dayForSection: must match the 'day' component in collectionView:layout:startTimeForItemAtIndexPath:", indexPath.section);
    
    return itemStartTime;
}

- (NSDateComponents *)endTimeForIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPath];
    NSDateComponents *itemEndTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    // Ensure the day component of the item is the same as the day component of the item's section
    NSDateComponents *day = [self dayForSection:indexPath.section];
    NSAssert1(day.day == itemEndTime.day, @"The 'day' date component (%i) from collectionView:layout:dayForSection: must match the 'day' component in collectionView:layout:endTimeForItemAtIndexPath:", indexPath.section);
    return itemEndTime;
}

- (NSDateComponents *)currentTimeDateComponents
{
    NSDate *date = [self.delegate currentTimeComponentsForCollectionView:self.collectionView layout:self];
    NSDateComponents *currentTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    return currentTime;
}

@end

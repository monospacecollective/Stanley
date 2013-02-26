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
NSString *const SFCollectionElementKindHorizontalGridline = @"SFCollectionElementKindHorizontalGridline";
NSString *const SFCollectionElementKindCurrentTimeHorizontalGridline = @"SFCollectionElementKindCurrentTimeHorizontalGridline";
NSString *const SFCollectionElementKindTimeRowHeaderBackground = @"SFCollectionElementKindTimeRowHeaderBackground";
NSString *const SFCollectionElementKindDayColumnHeaderBackground = @"SFCollectionElementKindDayColumnHeaderBackground";

@interface SFTimerWeakTarget : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
- (SEL)fireSelector;
@end

@implementation SFTimerWeakTarget
- (id)initWithTarget:(id)target selector:(SEL)selector
{
    self = [super init];
    if (self) {
        self.target = target;
        self.selector = selector;
    }
    return self;
}
- (void)fire:(NSTimer*)timer
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.target performSelector:self.selector withObject:timer];
#pragma clang diagnostic pop
}
- (SEL)fireSelector
{
    return @selector(fire:);
}
@end

@interface SFCollectionViewWeekLayout ()

// Minute Timer
@property (nonatomic, strong) NSTimer *minuteTimer;

// Caches
@property (nonatomic, strong) NSCache *cachedDayDateComponents;
@property (nonatomic, strong) NSCache *cachedStartTimeDateComponents;
@property (nonatomic, strong) NSCache *cachedEndTimeDateComponents;
@property (nonatomic, strong) NSCache *cachedCurrentDateComponents;
@property (nonatomic, assign) CGFloat cachedMaxColumnHeight;
@property (nonatomic, assign) NSInteger cachedEarliestHour;
@property (nonatomic, assign) NSInteger cachedLatestHour;
@property (nonatomic, strong) NSMutableDictionary *cachedColumnHeights;
@property (nonatomic, strong) NSMutableDictionary *cachedEarliestHours;
@property (nonatomic, strong) NSMutableDictionary *cachedLatestHours;
@property (nonatomic, strong) NSMutableDictionary *cachedItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *cachedHorizontalGridlineAttributes;

// Collection view decoration view removing Hack
@property (nonatomic, strong) NSMutableDictionary *registeredDecorationClasses;

// Contains the attributes for all items
@property (nonatomic, strong) NSMutableArray *allAttributes;

// Cell Attributes
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;

// Header Attributes (Row/Col)
@property (nonatomic, strong) NSMutableArray *dayColumnHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *timeRowHeaderAttributes;
@property (nonatomic, strong) NSMutableArray *dayColumnHeaderBackgroundAttributes;
@property (nonatomic, strong) NSMutableDictionary *timeRowHeaderBackgroundAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *currentTimeIndicatorAttributes;

// Gridlines
@property (nonatomic, strong) NSMutableDictionary *horizontalGridlineAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *currentTimeHorizontalGridlineAttributes;

@property (nonatomic, readonly) CGFloat minuteHeight;

- (void)minuteTick:(id)sender;

- (NSDate *)dateForTimeRowHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)maxColumnHeight;
- (CGFloat)stackedColumnHeight;
- (CGFloat)stackedColumnHeightUpToSection:(NSInteger)upToSection;
- (CGFloat)columnHeightForSection:(NSInteger)section;
- (CGFloat)minuteHeight;

- (CGFloat)zIndexForElementKind:(NSString *)elementKind;
- (CGFloat)zIndexForElementKind:(NSString *)elementKind floating:(BOOL)floating;

- (NSInteger)earliestHour;
- (NSInteger)latestHour;

- (NSInteger)earliestHourForSection:(NSInteger)section;
- (NSInteger)latestHourForSection:(NSInteger)section;

- (NSDateComponents *)dayForSection:(NSInteger)section;
- (NSDateComponents *)startTimeForIndexPath:(NSIndexPath *)indexPath;
- (NSDateComponents *)endTimeForIndexPath:(NSIndexPath *)indexPath;
- (NSDateComponents *)currentTimeDateComponents;

@end

@implementation SFCollectionViewWeekLayout

#pragma mark - NSObject

- (void)dealloc
{
    [self.minuteTimer invalidate];
    self.minuteTimer = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.cachedDayDateComponents = [NSCache new];
        self.cachedStartTimeDateComponents = [NSCache new];
        self.cachedEndTimeDateComponents = [NSCache new];
        self.cachedCurrentDateComponents = [NSCache new];
        self.cachedMaxColumnHeight = CGFLOAT_MIN;
        self.cachedEarliestHour = NSIntegerMax;
        self.cachedLatestHour = NSIntegerMin;
        self.cachedColumnHeights = [NSMutableDictionary new];
        self.cachedEarliestHours = [NSMutableDictionary new];
        self.cachedLatestHours = [NSMutableDictionary new];
        self.cachedItemAttributes = [NSMutableDictionary new];
        self.cachedHorizontalGridlineAttributes = [NSMutableDictionary new];
        
        self.registeredDecorationClasses = [NSMutableDictionary new];
        
        self.allAttributes = [NSMutableArray new];
        self.itemAttributes = [NSMutableDictionary new];
        self.dayColumnHeaderAttributes = [NSMutableArray new];
        self.dayColumnHeaderBackgroundAttributes = [NSMutableArray new];
        self.timeRowHeaderAttributes = [NSMutableDictionary new];
        self.timeRowHeaderBackgroundAttributes = [NSMutableDictionary new];
        self.horizontalGridlineAttributes = [NSMutableDictionary new];
        
        self.hourHeight = 60.0;
        self.sectionWidth = 236.0;
        self.dayColumnHeaderReferenceHeight = 60.0;
        self.timeRowHeaderReferenceWidth = 80.0;
        self.currentTimeIndicatorReferenceSize = CGSizeMake(86.0, 40.0);
        self.currentTimeHorizontalGridlineReferenceHeight = 9.0;
        self.horizontalGridlineReferenceHeight = 1.0;
        self.sectionMargin = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
        self.cellMargin = UIEdgeInsetsMake(0.0, 1.0, 1.0, 0.0);
        self.contentMargin = UIEdgeInsetsMake(30.0, 0.0, 60.0, 0.0);
        
        self.sectionLayoutType = SFWeekLayoutSectionLayoutTypeHorizontalTile;
        
        // Invalidate layout on minute ticks (to update the position of the current time indicator)
        NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:oneMinuteInFuture];
        NSDate *nextMinuteBoundary = [[NSCalendar currentCalendar] dateFromComponents:components];
        
        // This needs to be a weak reference, otherwise we get a retain cycle
        SFTimerWeakTarget *timerWeakTarget = [[SFTimerWeakTarget alloc] initWithTarget:self selector:@selector(minuteTick:)];
        self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:timerWeakTarget selector:timerWeakTarget.fireSelector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

#pragma mark - UICollectionViewLayout

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    // Invalidate cached Components
    [self.cachedDayDateComponents removeAllObjects];
    [self.cachedStartTimeDateComponents removeAllObjects];
    [self.cachedEndTimeDateComponents removeAllObjects];
    [self.cachedCurrentDateComponents removeAllObjects];
    
    // Invalidate Cached Interface Sizing Values
    self.cachedEarliestHour = NSIntegerMax;
    self.cachedLatestHour = NSIntegerMin;
    self.cachedMaxColumnHeight = CGFLOAT_MIN;
    [self.cachedColumnHeights removeAllObjects];
    [self.cachedEarliestHours removeAllObjects];
    [self.cachedLatestHours removeAllObjects];

    // Invalidate Cached Item Attributes
    [self.cachedItemAttributes removeAllObjects];
    [self.cachedHorizontalGridlineAttributes removeAllObjects];
}

- (void)finalizeCollectionViewUpdates
{
    // This is a hack to prevent the error detailed in :
    // http://stackoverflow.com/questions/12857301/uicollectionview-decoration-and-supplementary-views-can-not-be-moved
    // If this doesn't happen, whenever the collection view has batch updates performed on it, we get multiple instantiations of decoration classes
    for (UIView *subview in self.collectionView.subviews) {
        for (Class decorationViewClass in self.registeredDecorationClasses.allValues) {
            if ([subview isKindOfClass:decorationViewClass]) {
                [subview removeFromSuperview];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind
{
    [super registerClass:viewClass forDecorationViewOfKind:decorationViewKind];
    self.registeredDecorationClasses[decorationViewKind] = viewClass;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // Invalidate cached attributes
    [self.itemAttributes removeAllObjects];
    [self.horizontalGridlineAttributes removeAllObjects];
    [self.dayColumnHeaderAttributes removeAllObjects];
    [self.dayColumnHeaderBackgroundAttributes removeAllObjects];
    [self.timeRowHeaderAttributes removeAllObjects];
    [self.timeRowHeaderBackgroundAttributes removeAllObjects];
    
    switch (self.sectionLayoutType) {
        case SFWeekLayoutSectionLayoutTypeHorizontalTile:
            [self prepareHorizontalTileSectionLayout];
            break;
        case SFWeekLayoutSectionLayoutTypeVerticalTile:
            [self prepareVerticalTileSectionLayout];
            break;
    }
    
    // Rebuild the "all attributes" array
    [self.allAttributes removeAllObjects];
    [self.allAttributes addObjectsFromArray:self.dayColumnHeaderAttributes];
    [self.allAttributes addObjectsFromArray:self.dayColumnHeaderBackgroundAttributes];
    [self.allAttributes addObjectsFromArray:[self.timeRowHeaderAttributes allValues]];
    [self.allAttributes addObjectsFromArray:[self.timeRowHeaderBackgroundAttributes allValues]];
    [self.allAttributes addObjectsFromArray:[self.horizontalGridlineAttributes allValues]];
    [self.allAttributes addObjectsFromArray:[self.itemAttributes allValues]];
    if (self.currentTimeIndicatorAttributes) {
        [self.allAttributes addObject:self.currentTimeIndicatorAttributes];
    }
    if (self.currentTimeHorizontalGridlineAttributes) {
        [self.allAttributes addObject:self.currentTimeHorizontalGridlineAttributes];
    }
}

- (void)prepareHorizontalTileSectionLayout
{
    if (self.collectionView.numberOfSections == 0) {
        return;
    }
    
    NSInteger earliestHour = [self earliestHour];
    NSInteger latestHour = [self latestHour];
    
    CGFloat sectionWidth = (self.sectionMargin.left + self.sectionWidth + self.sectionMargin.right);
    CGFloat calendarGridMinX = (self.timeRowHeaderReferenceWidth + self.contentMargin.left);
    CGFloat calendarGridMinY = (self.dayColumnHeaderReferenceHeight + self.contentMargin.top);
    CGFloat calendarGridWidth = (self.collectionViewContentSize.width - self.timeRowHeaderReferenceWidth - self.contentMargin.right);
    
    // Time Row Header
    CGFloat timeRowHeaderMinX = fmaxf(self.collectionView.contentOffset.x, 0.0);
    CGFloat timeRowHeaderMinY = -nearbyintf(self.collectionView.frame.size.height / 2.0);
    
    // Time Row Header Backgound
    NSIndexPath *timeRowHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *timeRowHeaderBackgroundAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindTimeRowHeaderBackground withIndexPath:timeRowHeaderBackgroundIndexPath];
    CGFloat timeRowHeaderBackgroundHeight = fmaxf(self.collectionViewContentSize.height + self.collectionView.frame.size.height, self.collectionView.frame.size.height);
    timeRowHeaderBackgroundAttributes.frame = CGRectMake(timeRowHeaderMinX, timeRowHeaderMinY, self.timeRowHeaderReferenceWidth, timeRowHeaderBackgroundHeight);
    // Floating
    BOOL timeRowHeaderBackgroundFloating = (timeRowHeaderMinX != 0);
    timeRowHeaderBackgroundAttributes.hidden = !timeRowHeaderBackgroundFloating;
    timeRowHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindTimeRowHeaderBackground floating:timeRowHeaderBackgroundFloating];
    self.timeRowHeaderBackgroundAttributes[timeRowHeaderBackgroundIndexPath] = timeRowHeaderBackgroundAttributes;
    
    // The current time is within the day
    NSDateComponents *currentTimeDateComponents = [self currentTimeDateComponents];
    BOOL currentTimeIndicatorVisible = ((currentTimeDateComponents.hour >= earliestHour) && (currentTimeDateComponents.hour < latestHour));
    
    // Current Time Indicator
    self.currentTimeIndicatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.currentTimeHorizontalGridlineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindCurrentTimeHorizontalGridline withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    self.currentTimeIndicatorAttributes.hidden = !currentTimeIndicatorVisible;
    self.currentTimeHorizontalGridlineAttributes.hidden = !currentTimeIndicatorVisible;
    
    if (currentTimeIndicatorVisible) {
        // The y value of the current time
        CGFloat timeY = (calendarGridMinY + nearbyintf(((currentTimeDateComponents.hour - earliestHour) * self.hourHeight) + (currentTimeDateComponents.minute * self.minuteHeight)));
        
        CGFloat currentTimeIndicatorMinY = (timeY - nearbyintf(self.currentTimeIndicatorReferenceSize.height / 2.0));
        CGFloat currentTimeIndicatorMinX = (fmaxf(self.collectionView.contentOffset.x, 0.0) + (self.timeRowHeaderReferenceWidth - self.currentTimeIndicatorReferenceSize.width));
        self.currentTimeIndicatorAttributes.frame = (CGRect){{currentTimeIndicatorMinX, currentTimeIndicatorMinY}, self.currentTimeIndicatorReferenceSize};
        self.currentTimeIndicatorAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindCurrentTimeIndicator floating:timeRowHeaderBackgroundFloating];
        
        CGFloat currentTimeHorizontalGridlineMinY = (timeY - nearbyintf(self.currentTimeHorizontalGridlineReferenceHeight / 2.0));
        self.currentTimeHorizontalGridlineAttributes.frame = CGRectMake(calendarGridMinX, currentTimeHorizontalGridlineMinY, calendarGridWidth, self.currentTimeHorizontalGridlineReferenceHeight);
        self.currentTimeHorizontalGridlineAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindCurrentTimeHorizontalGridline];
    }
    
    // Day Column Header Background
    CGFloat dayColumnHeaderBackgroundMinY = fmaxf(self.collectionView.contentOffset.y, 0.0);
    CGFloat dayColumnHeaderBackgroundMinX = -nearbyintf(self.collectionView.frame.size.width / 2.0);
    CGFloat dayColumnHeaderBackgroundWidth = fmaxf(self.collectionViewContentSize.width + self.collectionView.frame.size.width, self.collectionView.frame.size.width);
    UICollectionViewLayoutAttributes *dayColumnHeaderBackgroundAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindDayColumnHeaderBackground withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    dayColumnHeaderBackgroundAttributes.frame = CGRectMake(dayColumnHeaderBackgroundMinX, dayColumnHeaderBackgroundMinY, dayColumnHeaderBackgroundWidth, self.dayColumnHeaderReferenceHeight);
    // Floating
    BOOL dayColumnHeaderBackgroundFloating = (dayColumnHeaderBackgroundMinY != 0);
    dayColumnHeaderBackgroundAttributes.hidden = !dayColumnHeaderBackgroundFloating;
    dayColumnHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindDayColumnHeaderBackground floating:dayColumnHeaderBackgroundFloating];
    self.dayColumnHeaderBackgroundAttributes[0] = dayColumnHeaderBackgroundAttributes;
    
    // Time Row Headers
    NSUInteger timeRowHeaderIndex = 0;
    for (NSInteger hour = earliestHour; hour <= latestHour; hour++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:timeRowHeaderIndex inSection:0];
        UICollectionViewLayoutAttributes *timeRowHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withIndexPath:indexPath];
        CGFloat titleRowHeaderMinY = (calendarGridMinY + (self.hourHeight * (hour - earliestHour)) - nearbyintf(self.hourHeight / 2.0));
        timeRowHeaderAttributes.frame = CGRectMake(timeRowHeaderMinX, titleRowHeaderMinY, self.timeRowHeaderReferenceWidth, self.hourHeight);
        timeRowHeaderAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindTimeRowHeader floating:timeRowHeaderBackgroundFloating];
        self.timeRowHeaderAttributes[indexPath] = timeRowHeaderAttributes;
        timeRowHeaderIndex++;
    }
    
    BOOL needsToPopulateCachedItemAttributes = (self.cachedItemAttributes.count == 0);
    if (!needsToPopulateCachedItemAttributes) {
        [self.itemAttributes addEntriesFromDictionary:self.cachedItemAttributes];
    }
    
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        
        CGFloat sectionMinX = (calendarGridMinX + self.sectionMargin.left + (sectionWidth * section));
        
        // Day Column Header
        UICollectionViewLayoutAttributes *dayColumnHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        dayColumnHeaderAttributes.frame = CGRectMake(sectionMinX, dayColumnHeaderBackgroundMinY, self.sectionWidth, self.dayColumnHeaderReferenceHeight);
        dayColumnHeaderAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindDayColumnHeader floating:dayColumnHeaderBackgroundFloating];
        self.dayColumnHeaderAttributes[section] = dayColumnHeaderAttributes;
        
        if (needsToPopulateCachedItemAttributes) {
            // Items
            NSMutableArray *sectionItemAttributes = [NSMutableArray new];
            for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                itemAttributes.zIndex = [self zIndexForElementKind:nil];
                
                NSDateComponents *itemStartTime = [self startTimeForIndexPath:indexPath];
                NSDateComponents *itemEndTime = [self endTimeForIndexPath:indexPath];
                
                CGFloat itemMinY = (((itemStartTime.hour - earliestHour) * self.hourHeight) + (itemStartTime.minute * self.minuteHeight) + calendarGridMinY + self.cellMargin.top);
                CGFloat itemMaxY = (((itemEndTime.hour - earliestHour) * self.hourHeight) + (itemEndTime.minute * self.minuteHeight) + calendarGridMinY - self.cellMargin.bottom);
                CGFloat itemMinX = (sectionMinX + self.cellMargin.left);
                CGFloat itemMaxX = (itemMinX + (self.sectionWidth - self.cellMargin.left - self.cellMargin.right));
                itemAttributes.frame = CGRectMake(itemMinX, itemMinY, (itemMaxX - itemMinX), (itemMaxY - itemMinY));
                
                self.itemAttributes[indexPath] = itemAttributes;
                [sectionItemAttributes addObject:itemAttributes];
                
                self.cachedItemAttributes[indexPath] = itemAttributes;
            }
            [self adjustItemsForOverlap:sectionItemAttributes inSection:section sectionMinX:sectionMinX];
        }
    }
    
    // Horizontal Gridlines
    if (self.cachedHorizontalGridlineAttributes.count == 0) {
        NSUInteger horizontalGridlineIndex = 0;
        for (NSInteger hour = earliestHour; hour <= latestHour; hour++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:horizontalGridlineIndex inSection:0];
            UICollectionViewLayoutAttributes *horizontalGridlineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindHorizontalGridline withIndexPath:indexPath];
            CGFloat horizontalGridlineMinY = (calendarGridMinY + (self.hourHeight * (hour - earliestHour))) - nearbyintf(self.horizontalGridlineReferenceHeight / 2.0);
            horizontalGridlineAttributes.frame = CGRectMake(calendarGridMinX, horizontalGridlineMinY, calendarGridWidth, self.horizontalGridlineReferenceHeight);
            self.horizontalGridlineAttributes[indexPath] = horizontalGridlineAttributes;
            self.cachedHorizontalGridlineAttributes[indexPath] = horizontalGridlineAttributes;
            horizontalGridlineIndex++;
        }
    } else {
        [self.horizontalGridlineAttributes addEntriesFromDictionary:self.cachedHorizontalGridlineAttributes];
    }
}

- (void)prepareVerticalTileSectionLayout
{
    if (self.collectionView.numberOfSections == 0) {
        return;
    }
    
    // Current Time Indicator
    self.currentTimeIndicatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindCurrentTimeIndicator withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.currentTimeHorizontalGridlineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindCurrentTimeHorizontalGridline withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    BOOL currentTimeIndicatorVisible = NO;
    
    BOOL needsToPopulateCachedItemAttributes = (self.cachedItemAttributes.count == 0);
    if (!needsToPopulateCachedItemAttributes) {
        [self.itemAttributes addEntriesFromDictionary:self.cachedItemAttributes];
    }
    
    BOOL needsToPopulateCachedHorizontalGridlineAttributes = (self.cachedHorizontalGridlineAttributes.count == 0);
    if (!needsToPopulateCachedHorizontalGridlineAttributes) {
        [self.horizontalGridlineAttributes addEntriesFromDictionary:self.cachedHorizontalGridlineAttributes];
    }
    
    CGFloat calendarGridMinX = (self.timeRowHeaderReferenceWidth + self.contentMargin.left);
    CGFloat calendarGridWidth = (self.collectionViewContentSize.width - self.timeRowHeaderReferenceWidth - self.contentMargin.left - self.contentMargin.right);
    
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        
        NSInteger earliestHour = [self earliestHourForSection:section];
        NSInteger latestHour = [self latestHourForSection:section];
        
        CGFloat columnMinY = (section == 0) ? 0.0 : [self stackedColumnHeightUpToSection:section];
        CGFloat calendarGridMinY = (columnMinY + self.dayColumnHeaderReferenceHeight + self.contentMargin.top);
        
        // Day Column Header Background
        CGFloat nextColumnMinY = (section == self.collectionView.numberOfSections) ? self.collectionViewContentSize.height : [self stackedColumnHeightUpToSection:(section + 1)];
        CGFloat dayColumnHeaderBackgroundMinX = -nearbyintf(self.collectionView.frame.size.width / 2.0);
        CGFloat dayColumnHeaderBackgroundWidth = fmaxf(self.collectionViewContentSize.width + self.collectionView.frame.size.width, self.collectionView.frame.size.width);
        CGFloat dayColumnHeaderMinY = fminf(fmaxf(self.collectionView.contentOffset.y, columnMinY), (nextColumnMinY - self.dayColumnHeaderReferenceHeight));
        UICollectionViewLayoutAttributes *dayColumnHeaderBackgroundAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindDayColumnHeaderBackground withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        dayColumnHeaderBackgroundAttributes.frame = CGRectMake(dayColumnHeaderBackgroundMinX, dayColumnHeaderMinY, dayColumnHeaderBackgroundWidth, self.dayColumnHeaderReferenceHeight);
        // Floating
        BOOL dayColumnHeaderFloating = (dayColumnHeaderMinY > columnMinY);
        dayColumnHeaderBackgroundAttributes.hidden = !dayColumnHeaderFloating;
        dayColumnHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindDayColumnHeaderBackground floating:dayColumnHeaderFloating];
        self.dayColumnHeaderBackgroundAttributes[section] = dayColumnHeaderBackgroundAttributes;
        
        NSDateComponents *currentDay = [self dayForSection:section];
        NSDateComponents *currentTimeDateComponents = [self currentTimeDateComponents];
        
        // The current time is within this section's day
        if ((currentTimeDateComponents.day == currentDay.day) && (currentTimeDateComponents.hour >= earliestHour) && (currentTimeDateComponents.hour < latestHour)) {
            
            currentTimeIndicatorVisible = YES;
            
            // The y value of the current time
            CGFloat timeY = (calendarGridMinY + nearbyintf(((currentTimeDateComponents.hour - earliestHour) * self.hourHeight) + (currentTimeDateComponents.minute * self.minuteHeight)));
            
            CGFloat currentTimeIndicatorMinY = (timeY - nearbyintf(self.currentTimeIndicatorReferenceSize.height / 2.0));
            CGFloat currentTimeIndicatorMinX = (self.timeRowHeaderReferenceWidth - self.currentTimeIndicatorReferenceSize.width);
            self.currentTimeIndicatorAttributes.frame = (CGRect){{currentTimeIndicatorMinX, currentTimeIndicatorMinY}, self.currentTimeIndicatorReferenceSize};
            self.currentTimeIndicatorAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindCurrentTimeIndicator];
            
            CGFloat currentTimeHorizontalGridlineMinY = (timeY - nearbyintf(self.currentTimeHorizontalGridlineReferenceHeight / 2.0));
            self.currentTimeHorizontalGridlineAttributes.frame = CGRectMake(calendarGridMinX, currentTimeHorizontalGridlineMinY, calendarGridWidth, self.currentTimeHorizontalGridlineReferenceHeight);
            self.currentTimeHorizontalGridlineAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindCurrentTimeHorizontalGridline];
        }
        
        // Time Row Headers
        NSUInteger timeRowHeaderIndex = 0;
        for (NSInteger hour = earliestHour; hour <= latestHour; hour++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:timeRowHeaderIndex inSection:section];
            UICollectionViewLayoutAttributes *timeRowHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindTimeRowHeader withIndexPath:indexPath];
            CGFloat titleRowHeaderMinY = (calendarGridMinY + (self.hourHeight * (hour - earliestHour)) - nearbyintf(self.hourHeight / 2.0));
            timeRowHeaderAttributes.frame = CGRectMake(0.0, titleRowHeaderMinY, self.timeRowHeaderReferenceWidth, self.hourHeight);
            timeRowHeaderAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindTimeRowHeader];
            self.timeRowHeaderAttributes[indexPath] = timeRowHeaderAttributes;
            timeRowHeaderIndex++;
        }
        
        // Day Column Header
        UICollectionViewLayoutAttributes *dayColumnHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SFCollectionElementKindDayColumnHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        dayColumnHeaderAttributes.frame = CGRectMake(0.0, dayColumnHeaderMinY, self.collectionViewContentSize.width, self.dayColumnHeaderReferenceHeight);
        dayColumnHeaderAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindDayColumnHeader floating:dayColumnHeaderFloating];
        self.dayColumnHeaderAttributes[section] = dayColumnHeaderAttributes;
        
        if (needsToPopulateCachedItemAttributes) {
            // Items
            NSMutableArray *sectionItemAttributes = [NSMutableArray new];
            for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                itemAttributes.zIndex = [self zIndexForElementKind:nil];
                
                NSDateComponents *itemStartTime = [self startTimeForIndexPath:indexPath];
                NSDateComponents *itemEndTime = [self endTimeForIndexPath:indexPath];
                
                CGFloat itemMinY = (calendarGridMinY + (((itemStartTime.hour - earliestHour) * self.hourHeight) + (itemStartTime.minute * self.minuteHeight) + self.cellMargin.top));
                CGFloat itemMaxY = (calendarGridMinY + (((itemEndTime.hour - earliestHour) * self.hourHeight) + (itemEndTime.minute * self.minuteHeight) - self.cellMargin.bottom));
                CGFloat itemMinX = (calendarGridMinX + self.sectionMargin.left + self.cellMargin.left);
                CGFloat itemMaxX = (itemMinX + (self.sectionWidth - self.cellMargin.left - self.cellMargin.right));
                itemAttributes.frame = CGRectMake(itemMinX, itemMinY, (itemMaxX - itemMinX), (itemMaxY - itemMinY));
                
                self.itemAttributes[indexPath] = itemAttributes;
                [sectionItemAttributes addObject:itemAttributes];
                
                self.cachedItemAttributes[indexPath] = itemAttributes;
            }
            [self adjustItemsForOverlap:sectionItemAttributes inSection:section sectionMinX:calendarGridMinX];
        }
        
        if (needsToPopulateCachedHorizontalGridlineAttributes) {
            // Horizontal Gridlines
            NSUInteger horizontalGridlineIndex = 0;
            for (NSInteger hour = earliestHour; hour <= latestHour; hour++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:horizontalGridlineIndex inSection:section];
                UICollectionViewLayoutAttributes *horizontalGridlineAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:SFCollectionElementKindHorizontalGridline withIndexPath:indexPath];
                CGFloat horizontalGridlineMinY = (calendarGridMinY + (self.hourHeight * (hour - earliestHour))) - nearbyintf(self.horizontalGridlineReferenceHeight / 2.0);
                horizontalGridlineAttributes.frame = CGRectMake(calendarGridMinX, horizontalGridlineMinY, calendarGridWidth, self.horizontalGridlineReferenceHeight);
                horizontalGridlineAttributes.zIndex = [self zIndexForElementKind:SFCollectionElementKindHorizontalGridline];
                self.horizontalGridlineAttributes[indexPath] = horizontalGridlineAttributes;
                self.cachedHorizontalGridlineAttributes[indexPath] = horizontalGridlineAttributes;
                horizontalGridlineIndex++;
            }
        }
    }
    
    self.currentTimeIndicatorAttributes.hidden = !currentTimeIndicatorVisible;
    self.currentTimeHorizontalGridlineAttributes.hidden = !currentTimeIndicatorVisible;
}

- (void)adjustItemsForOverlap:(NSArray *)sectionItemAttributes inSection:(NSUInteger)section sectionMinX:(CGFloat)sectionMinX
{
    for (UICollectionViewLayoutAttributes *itemAttributes in sectionItemAttributes) {
        
        NSMutableArray *overlappingItems = [NSMutableArray new];
        CGRect itemFrame = itemAttributes.frame;
        [overlappingItems addObjectsFromArray:[sectionItemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
            if (layoutAttributes != itemAttributes) {
                return CGRectIntersectsRect(itemFrame, layoutAttributes.frame);
            } else {
                return NO;
            }
        }]]];
        if (overlappingItems.count) {
            [overlappingItems insertObject:itemAttributes atIndex:0];
            CGFloat minY = CGFLOAT_MAX;
            CGFloat maxY = CGFLOAT_MIN;
            for (UICollectionViewLayoutAttributes *overlappingItemAttributes in overlappingItems) {
                if (CGRectGetMinY(overlappingItemAttributes.frame) < minY) {
                    minY = CGRectGetMinY(overlappingItemAttributes.frame);
                }
                if (CGRectGetMaxY(overlappingItemAttributes.frame) > maxY) {
                    maxY = CGRectGetMaxY(overlappingItemAttributes.frame);
                }
            }
            NSInteger divisions = 1;
            for (CGFloat currentY = minY; currentY <= maxY; currentY += 1.0) {
                NSInteger numItemsForCurrentY = 0;
                for (UICollectionViewLayoutAttributes *overlappingItemAttributes in overlappingItems) {
                    if ((currentY >= CGRectGetMinY(overlappingItemAttributes.frame)) && (currentY < CGRectGetMaxY(overlappingItemAttributes.frame))) {
                        numItemsForCurrentY++;
                    }
                }
                if (numItemsForCurrentY > divisions) {
                    divisions = numItemsForCurrentY;
                }
            }
            CGFloat divisionWidth = floorf(self.sectionWidth / divisions);
            NSMutableArray *dividedAttributes = [NSMutableArray array];
            for (UICollectionViewLayoutAttributes *divisionAttributes in overlappingItems) {
                CGRect divisionAttributesFrame = divisionAttributes.frame;
                divisionAttributesFrame.size.width = (divisionWidth - self.cellMargin.left - self.cellMargin.right);
                for (UICollectionViewLayoutAttributes *dividedItemAttributes in dividedAttributes) {
                    NSInteger scoot = 0;
                    while (CGRectIntersectsRect(dividedItemAttributes.frame, divisionAttributesFrame)) {
                        divisionAttributesFrame.origin.x = sectionMinX + ((divisionWidth * (scoot % divisions)) + self.cellMargin.left);
                        scoot++;
                    }
                }
                divisionAttributes.frame = divisionAttributesFrame;
                [dividedAttributes addObject:divisionAttributes];
            }
        }
    }
}

- (CGSize)collectionViewContentSize
{
    CGFloat width;
    CGFloat height;
    switch (self.sectionLayoutType) {
        case SFWeekLayoutSectionLayoutTypeHorizontalTile:
            height = [self maxColumnHeight];
            width = (self.timeRowHeaderReferenceWidth + self.contentMargin.left + ((self.sectionMargin.left + self.sectionWidth + self.sectionMargin.right) * self.collectionView.numberOfSections) + self.contentMargin.right);
            break;
        case SFWeekLayoutSectionLayoutTypeVerticalTile:
            height = [self stackedColumnHeight];
            width = (self.timeRowHeaderReferenceWidth + self.contentMargin.left + self.sectionMargin.left + self.sectionWidth + self.sectionMargin.right + self.contentMargin.right);
            break;
    }
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
        return self.timeRowHeaderAttributes[indexPath];
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([decorationViewKind isEqualToString:SFCollectionElementKindCurrentTimeIndicator]) {
        return self.currentTimeIndicatorAttributes;
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementKindHorizontalGridline]) {
        return self.horizontalGridlineAttributes[indexPath];
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementKindCurrentTimeHorizontalGridline]) {
        return self.currentTimeHorizontalGridlineAttributes;
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementKindTimeRowHeaderBackground]) {
        return self.timeRowHeaderBackgroundAttributes[indexPath];
    }
    else if ([decorationViewKind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
        return self.dayColumnHeaderBackgroundAttributes[indexPath.section];
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
    // Required for sticky headers
    return YES;
}

#pragma mark - SFCollectionViewWeekLayout

- (void)minuteTick:(id)sender
{
    // Invalidate cached current date componets (since the minute's changed!)
    [self.cachedCurrentDateComponents removeAllObjects];
    [self invalidateLayout];
}

- (NSDate *)dateForTimeRowHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger earliestHour;
    switch (self.sectionLayoutType) {
        case SFWeekLayoutSectionLayoutTypeHorizontalTile:
            earliestHour = [self earliestHour];
            break;
        case SFWeekLayoutSectionLayoutTypeVerticalTile:
            earliestHour = [self earliestHourForSection:indexPath.section];
            break;
    }
    NSDateComponents *dateComponents = [self dayForSection:indexPath.section];
    dateComponents.hour = (earliestHour + indexPath.item);
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

- (NSDate *)dateForDayColumnHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.delegate collectionView:self.collectionView layout:self dayForSection:indexPath.section] beginningOfDay];
}

- (void)scrollCollectionViewToClosetSectionToCurrentTimeAnimated:(BOOL)animated
{
    if (self.collectionView.numberOfSections != 0) {
        NSInteger closestSectionToCurrentTime = [self closestSectionToCurrentTime];
        CGPoint contentOffset;
        if (self.sectionLayoutType == SFWeekLayoutSectionLayoutTypeHorizontalTile) {
            CGFloat yOffset;
            if (!CGRectEqualToRect(self.currentTimeHorizontalGridlineAttributes.frame, CGRectZero)) {
                yOffset = nearbyintf(CGRectGetMinY(self.currentTimeHorizontalGridlineAttributes.frame) - (CGRectGetHeight(self.collectionView.frame) / 2.0));
            } else {
                yOffset = 0.0;
            }
            contentOffset = CGPointMake(self.contentMargin.left + ((self.sectionMargin.left + self.sectionWidth + self.sectionMargin.right) * closestSectionToCurrentTime), yOffset);
        } else {
            CGFloat yOffset;
            if (!CGRectEqualToRect(self.currentTimeHorizontalGridlineAttributes.frame, CGRectZero)) {
                yOffset = fmaxf(nearbyintf(CGRectGetMinY(self.currentTimeHorizontalGridlineAttributes.frame) - (CGRectGetHeight(self.collectionView.frame) / 2.0)), [self stackedColumnHeightUpToSection:closestSectionToCurrentTime]);
            } else {
                yOffset = [self stackedColumnHeightUpToSection:closestSectionToCurrentTime];
            }
            contentOffset = CGPointMake(0.0, yOffset);
        }
        // Prevent the content offset from forcing the scroll view content off its bounds
        if (contentOffset.y > (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
            contentOffset.y = (self.collectionView.contentSize.height - self.collectionView.frame.size.height);
        }
        if (contentOffset.y < 0.0) {
            contentOffset.y = 0.0;
        }
        if (contentOffset.x > (self.collectionView.contentSize.width - self.collectionView.frame.size.width)) {
            contentOffset.x = (self.collectionView.contentSize.width - self.collectionView.frame.size.width);
        }
        if (contentOffset.x < 0.0) {
            contentOffset.x = 0.0;
        }
        [self.collectionView setContentOffset:contentOffset animated:animated];
    }
}

- (NSInteger)closestSectionToCurrentTime
{
    NSDate *currentDate = [[self.delegate currentTimeComponentsForCollectionView:self.collectionView layout:self] beginningOfDay];
    NSTimeInterval minTimeInterval = CGFLOAT_MAX;
    NSInteger closestSection = NSIntegerMax;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        NSDate *sectionDayDate = [self.delegate collectionView:self.collectionView layout:self dayForSection:section];
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:sectionDayDate];
        if ((timeInterval <= 0) && abs(timeInterval) < minTimeInterval) {
            minTimeInterval = abs(timeInterval);
            closestSection = section;
        }
    }
    return ((closestSection != NSIntegerMax) ? closestSection : 0);
}

#pragma mark Column Heights

- (CGFloat)maxColumnHeight
{
    if (self.cachedMaxColumnHeight != CGFLOAT_MIN) {
        return self.cachedMaxColumnHeight;
    }
    CGFloat maxColumnHeight = 0.0;
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        
        NSInteger earliestHour = [self earliestHour];
        NSInteger latestHour = [self latestHourForSection:section];
        CGFloat sectionColumnHeight;
        if ((earliestHour != NSUndefinedDateComponent) && (latestHour != NSUndefinedDateComponent)) {
            sectionColumnHeight = (self.hourHeight * (latestHour - earliestHour));
        } else {
            sectionColumnHeight = 0.0;
        }
        
        if (sectionColumnHeight > maxColumnHeight) {
            maxColumnHeight = sectionColumnHeight;
        }
    }
    CGFloat headerAdjustedMaxColumnHeight = (maxColumnHeight + (self.dayColumnHeaderReferenceHeight + self.contentMargin.top + self.contentMargin.bottom));
    if (maxColumnHeight != 0.0) {
        self.cachedMaxColumnHeight = headerAdjustedMaxColumnHeight;
        return headerAdjustedMaxColumnHeight;
    } else {
        return headerAdjustedMaxColumnHeight;
    }
}

- (CGFloat)stackedColumnHeight
{
    return [self stackedColumnHeightUpToSection:self.collectionView.numberOfSections];
}

- (CGFloat)stackedColumnHeightUpToSection:(NSInteger)upToSection
{
    if (self.cachedColumnHeights[@(upToSection)]) {
        return [self.cachedColumnHeights[@(upToSection)] integerValue];
    }
    CGFloat stackedColumnHeight = 0.0;
    for (NSInteger section = 0; section < upToSection; section++) {
        CGFloat sectionColumnHeight = [self columnHeightForSection:section];
        stackedColumnHeight += sectionColumnHeight;
    }
    CGFloat headerAdjustedStackedColumnHeight = (stackedColumnHeight + ((self.dayColumnHeaderReferenceHeight + self.contentMargin.top + self.contentMargin.bottom) * upToSection));
    if (stackedColumnHeight != 0.0) {
        self.cachedColumnHeights[@(upToSection)] = @(headerAdjustedStackedColumnHeight);
        return headerAdjustedStackedColumnHeight;
    } else {
        return headerAdjustedStackedColumnHeight;
    }
}

- (CGFloat)columnHeightForSection:(NSInteger)section
{
    NSInteger earliestHour = [self earliestHourForSection:section];
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

- (CGFloat)zIndexForElementKind:(NSString *)elementKind
{
    return [self zIndexForElementKind:elementKind floating:NO];
}

- (CGFloat)zIndexForElementKind:(NSString *)elementKind floating:(BOOL)floating
{
    switch (self.sectionLayoutType) {
        case SFWeekLayoutSectionLayoutTypeHorizontalTile: {
            // Current Time Indicator
            if ([elementKind isEqualToString:SFCollectionElementKindCurrentTimeIndicator]) {
                return (floating ? 12.0 : 7.0);
            }
            // Time Row Header
            else if ([elementKind isEqualToString:SFCollectionElementKindTimeRowHeader]) {
                return (floating ? 11.0 : 6.0);
            }
            // Time Row Header Background
            else if ([elementKind isEqualToString:SFCollectionElementKindTimeRowHeaderBackground]) {
                return (floating ? 10.0 : 5.0);
            }
            // Day Column Header
            else if ([elementKind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
                return (floating ? 9.0 : 4.0);
            }
            // Day Column Header Background
            else if ([elementKind isEqualToString:SFCollectionElementKindDayColumnHeaderBackground]) {
                return (floating ? 8.0 : 3.0);
            }
            // Cell
            else if (elementKind == nil) {
                return 2.0;
            }
            // Current Time Horizontal Gridline
            else if ([elementKind isEqualToString:SFCollectionElementKindCurrentTimeHorizontalGridline]) {
                return 1.0;
            }
            // Horizontal Gridline
            else if ([elementKind isEqualToString:SFCollectionElementKindHorizontalGridline]) {
                return 0.0;
            }
        }
        case SFWeekLayoutSectionLayoutTypeVerticalTile: {
            // Day Column Header
            if ([elementKind isEqualToString:SFCollectionElementKindDayColumnHeader]) {
                return (floating ? 9.0 : 7.0);
            }
            // Day Column Header Background
            else if ([elementKind isEqualToString:SFCollectionElementKindDayColumnHeaderBackground]) {
                return (floating ? 8.0 : 6.0);
            }
            // Current Time Indicator
            else if ([elementKind isEqualToString:SFCollectionElementKindCurrentTimeIndicator]) {
                return 5.0;
            }
            // Time Row Header
            if ([elementKind isEqualToString:SFCollectionElementKindTimeRowHeader]) {
                return 4.0;
            }
            // Time Row Header Background
            else if ([elementKind isEqualToString:SFCollectionElementKindTimeRowHeaderBackground]) {
                return 3.0;
            }
            // Cell
            else if (elementKind == nil) {
                return 2.0;
            }
            // Current Time Horizontal Gridline
            else if ([elementKind isEqualToString:SFCollectionElementKindCurrentTimeHorizontalGridline]) {
                return 1.0;
            }
            // Horizontal Gridline
            else if ([elementKind isEqualToString:SFCollectionElementKindHorizontalGridline]) {
                return 0.0;
            }
        }
    }
    return CGFLOAT_MIN;
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
    if (self.cachedEarliestHours[@(section)]) {
        return [self.cachedEarliestHours[@(section)] integerValue];
    }
    NSInteger earliestHour = NSIntegerMax;
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        NSDateComponents *itemStartTime = [self startTimeForIndexPath:itemIndexPath];
        if (itemStartTime.hour < earliestHour) {
            earliestHour = itemStartTime.hour;
        }
    }
    if (earliestHour != NSIntegerMax) {
        self.cachedEarliestHours[@(section)] = @(earliestHour);
        return earliestHour;
    } else {
        return 0;
    }
}

- (NSInteger)latestHourForSection:(NSInteger)section
{
    if (self.cachedLatestHours[@(section)]) {
        return [self.cachedLatestHours[@(section)] integerValue];
    }
    NSInteger latestHour = NSIntegerMin;
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        NSDateComponents *itemEndTime = [self endTimeForIndexPath:itemIndexPath];
        NSInteger itemEndTimeHour = (itemEndTime.hour + ((itemEndTime.minute > 0) ? 1 : 0));
        if (itemEndTimeHour > latestHour) {
            latestHour = itemEndTimeHour;
        }
    }
    if (latestHour != NSIntegerMin) {
        self.cachedLatestHours[@(section)] = @(latestHour);
        return latestHour;
    } else {
        return 0;
    }
}

#pragma mark Delegate Wrappers

- (NSDateComponents *)dayForSection:(NSInteger)section
{
    if ([self.cachedDayDateComponents objectForKey:@(section)]) {
        return [self.cachedDayDateComponents objectForKey:@(section)];
    }
    
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self dayForSection:section];
    NSDateComponents *dayDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:date];
    
    [self.cachedDayDateComponents setObject:dayDateComponents forKey:@(section)];
    return dayDateComponents;
}

- (NSDateComponents *)startTimeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedStartTimeDateComponents objectForKey:indexPath]) {
        return [self.cachedStartTimeDateComponents objectForKey:indexPath];
    }
    
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self startTimeForItemAtIndexPath:indexPath];
    NSDateComponents *itemStartTimeDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    [self.cachedStartTimeDateComponents setObject:itemStartTimeDateComponents forKey:indexPath];
    return itemStartTimeDateComponents;
}

- (NSDateComponents *)endTimeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedEndTimeDateComponents objectForKey:indexPath]) {
        return [self.cachedEndTimeDateComponents objectForKey:indexPath];
    }
    
    NSDate *date = [self.delegate collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPath];
    NSDateComponents *itemEndTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    [self.cachedEndTimeDateComponents setObject:itemEndTime forKey:indexPath];
    return itemEndTime;
}

- (NSDateComponents *)currentTimeDateComponents
{
    if ([self.cachedCurrentDateComponents objectForKey:@(0)]) {
        return [self.cachedCurrentDateComponents objectForKey:@(0)];
    }
    
    NSDate *date = [self.delegate currentTimeComponentsForCollectionView:self.collectionView layout:self];
    NSDateComponents *currentTime = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    [self.cachedCurrentDateComponents setObject:currentTime forKey:@(0)];
    return currentTime;
}

@end

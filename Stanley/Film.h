//
//  Film.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Film : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSNumber * runtime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSString * synopsis;
@property (nonatomic, retain) NSString * featureImage;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * filmography;
@property (nonatomic, retain) NSString * printSource;
@property (nonatomic, retain) NSString * ticketURL;
@property (nonatomic, retain) NSString * trailerURL;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * rating;
@property (nonatomic, retain) NSDate * available;
@property (nonatomic, retain) NSSet *directors;
@property (nonatomic, retain) NSSet *writers;
@property (nonatomic, retain) NSSet *producers;
@property (nonatomic, retain) NSSet *stars;
@property (nonatomic, retain) NSSet *showings;

- (NSString *)runtimeString;

- (NSString *)directorsTitleString;
- (NSString *)writersTitleString;
- (NSString *)producersTitleString;
- (NSString *)starsTitleString;

- (NSString *)directorsListSeparatedByString:(NSString *)string;
- (NSString *)writersListSeparatedByString:(NSString *)string;
- (NSString *)producersListSeparatedByString:(NSString *)string;
- (NSString *)starsListSeparatedByString:(NSString *)string;

- (NSArray *)sortedShowings;

@end

@interface Film (CoreDataGeneratedAccessors)

- (void)addDirectorsObject:(NSManagedObject *)value;
- (void)removeDirectorsObject:(NSManagedObject *)value;
- (void)addDirectors:(NSSet *)values;
- (void)removeDirectors:(NSSet *)values;

- (void)addWritersObject:(NSManagedObject *)value;
- (void)removeWritersObject:(NSManagedObject *)value;
- (void)addWriters:(NSSet *)values;
- (void)removeWriters:(NSSet *)values;

- (void)addProducersObject:(NSManagedObject *)value;
- (void)removeProducersObject:(NSManagedObject *)value;
- (void)addProducers:(NSSet *)values;
- (void)removeProducers:(NSSet *)values;

- (void)addStarsObject:(NSManagedObject *)value;
- (void)removeStarsObject:(NSManagedObject *)value;
- (void)addStars:(NSSet *)values;
- (void)removeStars:(NSSet *)values;

@end

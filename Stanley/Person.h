//
//  Person.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Film;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *directed;
@property (nonatomic, retain) Film *starred;
@property (nonatomic, retain) Film *produced;
@property (nonatomic, retain) Film *wrote;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addDirectedObject:(Film *)value;
- (void)removeDirectedObject:(Film *)value;
- (void)addDirected:(NSSet *)values;
- (void)removeDirected:(NSSet *)values;

@end

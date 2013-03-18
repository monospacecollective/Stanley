//
//  SFPerson.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SFFilm;

@interface SFPerson : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *directed;
@property (nonatomic, retain) SFFilm *starred;
@property (nonatomic, retain) SFFilm *produced;
@property (nonatomic, retain) SFFilm *wrote;
@end

@interface SFPerson (CoreDataGeneratedAccessors)

- (void)addDirectedObject:(SFFilm *)value;
- (void)removeDirectedObject:(SFFilm *)value;
- (void)addDirected:(NSSet *)values;
- (void)removeDirected:(NSSet *)values;

@end

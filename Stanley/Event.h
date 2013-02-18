//
//  Event.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * detail;

- (NSUInteger)day;

@end

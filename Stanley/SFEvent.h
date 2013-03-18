//
//  SFEvent.h
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SFLocation;
@class SFFilm;

@interface SFEvent : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * featureImage;
@property (nonatomic, retain) NSString * ticketURL;
@property (nonatomic, retain) SFLocation *location;
@property (nonatomic, retain) SFFilm *film;

@property (nonatomic, retain) NSNumber * filmRemoteID;
@property (nonatomic, retain) NSNumber * locationRemoteID;

- (NSDate *)day;

@end

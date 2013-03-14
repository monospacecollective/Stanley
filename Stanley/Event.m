//
//  Event.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "Event.h"
#import "Film.h"
#import "Location.h"

@interface Event ()

@property (nonatomic, retain) NSString *primitiveDetail;
@property (nonatomic, retain) NSString *primitiveName;
@property (nonatomic, retain) NSNumber *primitiveFavorite;
@property (nonatomic, retain) NSString *primitiveFeatureImage;

@end

@implementation Event

@dynamic remoteID;
@dynamic name;
@dynamic start;
@dynamic end;
@dynamic detail;
@dynamic favorite;
@dynamic featureImage;
@dynamic ticketURL;
@dynamic film;
@dynamic location;

@dynamic primitiveDetail;
@dynamic primitiveName;
@dynamic primitiveFavorite;
@dynamic primitiveFeatureImage;

- (NSString *)detail
{
    if (self.film) {
        return self.film.detail;
    } else {
        return self.primitiveDetail;
    }
}

- (NSString *)name
{
    if (self.film) {
        return self.film.name;
    } else {
        return self.primitiveName;
    }
}

- (NSNumber *)favorite
{
    if (self.film) {
        return self.film.favorite;
    } else {
        return [self primitiveValueForKey:@"favorite"];
    }
}

- (void)setFavorite:(NSNumber *)favorite
{
    [self willChangeValueForKey:@"favorite"];
    if (self.film) {
        [self.film setFavorite:favorite];
    } else {
        [self setPrimitiveValue:favorite forKey:@"favorite"];
    }
    [self didChangeValueForKey:@"favorite"];
}

- (NSString *)featureImage
{
    if (self.film) {
        return self.film.featureImage;
    } else {
        return self.primitiveFeatureImage;
    }
}

- (void)setFilmRemoteID:(NSNumber *)filmRemoteID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Film"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(remoteID == %@)", filmRemoteID];
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    self.film = (objects.count ? objects[0] : nil);
}

- (NSNumber *)filmRemoteID
{
    return self.film.remoteID;
}

- (void)setLocationRemoteID:(NSNumber *)locationRemoteID
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(remoteID == %@)", locationRemoteID];
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    self.location = (objects.count ? objects[0] : nil);
}

- (NSNumber *)locationRemoteID
{
    return self.location.remoteID;
}

- (NSDate *)day
{
    return [self.start beginningOfDay];
}


@end

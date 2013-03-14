//
//  Film.m
//  Stanley
//
//  Created by Eric Horacek on 2/12/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "Film.h"


@implementation Film

@dynamic remoteID;
@dynamic language;
@dynamic runtime;
@dynamic name;
@dynamic detail;
@dynamic synopsis;
@dynamic featureImage;
@dynamic favorite;
@dynamic country;
@dynamic filmography;
@dynamic printSource;
@dynamic ticketURL;
@dynamic trailerURL;
@dynamic year;
@dynamic rating;
@dynamic available;
@dynamic directors;
@dynamic writers;
@dynamic producers;
@dynamic stars;
@dynamic showings;

- (NSString *)runtimeString
{
    NSInteger runtime = [self.runtime integerValue];
    if (runtime >= 60) {
        return [NSString stringWithFormat:@"%dh %dm", (runtime / 60), (runtime % 60)];
    } else {
        return [NSString stringWithFormat:@"%dm", runtime];
    }
}

- (NSString *)directorsTitleString
{
    return [((self.directors.count == 1) ? @"director" : @"directors") uppercaseString];
}

- (NSString *)writersTitleString
{
    return [((self.writers.count == 1) ? @"writer" : @"writers") uppercaseString];
}

- (NSString *)producersTitleString
{
    return [((self.producers.count == 1) ? @"producer" : @"producers") uppercaseString];
}

- (NSString *)starsTitleString
{
    return [@"cast" uppercaseString];
}

- (NSString *)directorsListSeparatedByString:(NSString *)string
{
    return [[[self.directors allObjects] valueForKey:@"name"] componentsJoinedByString:string];
}

- (NSString *)writersListSeparatedByString:(NSString *)string
{
    return [[[self.writers allObjects] valueForKey:@"name"] componentsJoinedByString:string];
}

- (NSString *)producersListSeparatedByString:(NSString *)string
{
    return [[[self.producers allObjects] valueForKey:@"name"] componentsJoinedByString:string];
}

- (NSString *)starsListSeparatedByString:(NSString *)string
{
    return [[[self.stars allObjects] valueForKey:@"name"] componentsJoinedByString:string];
}

- (NSArray *)sortedShowings
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(film == %@)", self];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

@end

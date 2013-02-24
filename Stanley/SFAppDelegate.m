//
//  SFAppDelegate.m
//  Stanley
//
//  Created by Eric Horacek on 2/11/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFAppDelegate.h"
#import "Film.h"
#import "SFFilmsViewController.h"
#import "SFNavigationBar.h"
#import "SFStyleManager.h"
#import "SFMasterViewController.h"

@interface SFAppDelegate ()

- (void)setupRestKitWithBaseURL:(NSURL *)baseURL;

@end

@implementation SFAppDelegate

- (void)setupRestKitWithBaseURL:(NSURL *)baseURL
{
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseURL];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Set the API key
    [objectManager.HTTPClient setDefaultHeader:@"api-key" value:@"PtPMvMRSiZiLvhUQLrVmfoGkwVSlpMSpxKWwCKhcdNT4YaGz2w"];
    [objectManager.HTTPClient setDefaultHeader:@"bundle-id" value:[[NSBundle mainBundle] bundleIdentifier]];
    
    // Initialize managed object store
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    RKEntityMapping *filmMapping = [RKEntityMapping mappingForEntityForName:@"Film" inManagedObjectStore:managedObjectStore];
    filmMapping.identificationAttributes = @[ @"remoteID" ];
    [filmMapping addAttributeMappingsFromArray:@[ @"name", @"synposis", @"language", @"runtime" ]];
    [filmMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"description" : @"detail", @"feature_image" : @"featureImage" }];
    
    RKEntityMapping *personMapping = [RKEntityMapping mappingForEntityForName:@"Person" inManagedObjectStore:managedObjectStore];
    personMapping.identificationAttributes = @[ @"remoteID" ];
    [personMapping addAttributeMappingsFromArray:@[ @"name" ]];
    [personMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID" }];
    
    RKEntityMapping *eventMapping = [RKEntityMapping mappingForEntityForName:@"Event" inManagedObjectStore:managedObjectStore];
    eventMapping.identificationAttributes = @[ @"remoteID" ];
    [eventMapping addAttributeMappingsFromArray:@[ @"name" ]];
    [eventMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"start_datetime" : @"start", @"end_datetime" : @"end", @"description" : @"detail" }];
    
    RKEntityMapping *announcementMapping = [RKEntityMapping mappingForEntityForName:@"Announcement" inManagedObjectStore:managedObjectStore];
    announcementMapping.identificationAttributes = @[ @"remoteID" ];
    [announcementMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
    [announcementMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"publish_datetime" : @"published" }];
    
    RKEntityMapping *locationMapping = [RKEntityMapping mappingForEntityForName:@"Location" inManagedObjectStore:managedObjectStore];
    locationMapping.identificationAttributes = @[ @"remoteID" ];
    [locationMapping addAttributeMappingsFromArray:@[ @"name", @"latitude", @"longitude" ]];
    [locationMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"description" : @"detail" }];
    
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"directors" toKeyPath:@"directors" withMapping:personMapping]];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"writers" toKeyPath:@"writers" withMapping:personMapping]];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stars" toKeyPath:@"stars" withMapping:personMapping]];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"producers" toKeyPath:@"producers" withMapping:personMapping]];
    
    RKResponseDescriptor *flimIndexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:filmMapping pathPattern:@"/films.json" keyPath:@"film" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:flimIndexResponseDescriptor];
    
    RKResponseDescriptor *eventIndexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventMapping pathPattern:@"/events.json" keyPath:@"event" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:eventIndexResponseDescriptor];
    
    RKResponseDescriptor *announcementIndexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:announcementMapping pathPattern:@"/announcements.json" keyPath:@"announcement" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:announcementIndexResponseDescriptor];

    RKResponseDescriptor *locationIndexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:locationMapping pathPattern:@"/locations.json" keyPath:@"location" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:locationIndexResponseDescriptor];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/films.json"];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Film"];
            fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
            return fetchRequest;
        }
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/events.json"];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
            fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
            return fetchRequest;
        }
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/announcements.json"];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Announcement"];
            fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES] ];
            return fetchRequest;
        }
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/locations.json"];
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
            fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
            return fetchRequest;
        }
        return nil;
    }];
    
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Stanley.sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    [managedObjectStore createManagedObjectContexts];
    
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
//    RKLogConfigureByName("RestKit/CoreData", RKLogLevelDebug);
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"MST"]];
    
    [self setupRestKitWithBaseURL:[NSURL URLWithString:@"http://stanley-film.herokuapp.com"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.navigationPaneViewController = [[MSNavigationPaneViewController alloc] init];
    self.navigationPaneViewController.openDirection = MSNavigationPaneOpenDirectionTop;
    self.navigationPaneViewController.paneViewSlideOffAnimationEnabled = NO;
    self.navigationPaneViewController.openStateRevealWidth = ((44.0 * SFPaneTypeCount) + 20.0);
    self.navigationPaneViewController.appearanceType = MSNavigationPaneAppearanceTypeFade;
    
    SFMasterViewController *masterViewController = [[SFMasterViewController alloc] initWithNibName:nil bundle:nil];
    masterViewController.navigationPaneViewController = self.navigationPaneViewController;
    self.navigationPaneViewController.masterViewController = masterViewController;
    
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = self.navigationPaneViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

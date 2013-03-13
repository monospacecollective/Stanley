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
#import "SFSplashViewController.h"

@interface SFAppDelegate ()

- (void)setupRestKitWithBaseURL:(NSURL *)baseURL;
- (void)setupPonyDebugger;

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
    [filmMapping addAttributeMappingsFromArray:@[ @"name", @"synposis", @"language", @"runtime", @"rating", @"filmography", @"country" ]];
    [filmMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"description" : @"detail", @"feature_image" : @"featureImage", @"print_source" : @"printSource", @"available_datetime" : @"available", @"ticket_url" : @"ticketURL" }];
    
    RKEntityMapping *personMapping = [RKEntityMapping mappingForEntityForName:@"Person" inManagedObjectStore:managedObjectStore];
    personMapping.identificationAttributes = @[ @"remoteID" ];
    [personMapping addAttributeMappingsFromArray:@[ @"name" ]];
    [personMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID" }];
    
    RKEntityMapping *eventMapping = [RKEntityMapping mappingForEntityForName:@"Event" inManagedObjectStore:managedObjectStore];
    eventMapping.identificationAttributes = @[ @"remoteID" ];
    [eventMapping addAttributeMappingsFromArray:@[ @"name" ]];
    [eventMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"start_datetime" : @"start", @"end_datetime" : @"end", @"description" : @"detail", @"retina_feature_image" : @"featureImage", @"ticket_url" : @"ticketURL" }];
    
    RKEntityMapping *locationMapping = [RKEntityMapping mappingForEntityForName:@"Location" inManagedObjectStore:managedObjectStore];
    locationMapping.identificationAttributes = @[ @"remoteID" ];
    [locationMapping addAttributeMappingsFromArray:@[ @"name", @"latitude", @"longitude" ]];
    [locationMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"description" : @"detail" }];
    
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"directors" toKeyPath:@"directors" withMapping:personMapping]];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"writers" toKeyPath:@"writers" withMapping:personMapping]];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stars" toKeyPath:@"stars" withMapping:personMapping]];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"producers" toKeyPath:@"producers" withMapping:personMapping]];
    
    [eventMapping addAttributeMappingsFromDictionary:@{ @"film_id" : @"filmRemoteID" }];
    [filmMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"showings" toKeyPath:@"showings" withMapping:eventMapping]];
    [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"film" toKeyPath:@"film" withMapping:filmMapping]];
    
    [eventMapping addAttributeMappingsFromDictionary:@{ @"location_id" : @"locationRemoteID" }];
    [locationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"events" toKeyPath:@"events" withMapping:eventMapping]];
    [eventMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    RKResponseDescriptor *flimIndexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:filmMapping pathPattern:@"/films.json" keyPath:@"film" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:flimIndexResponseDescriptor];
    
    RKResponseDescriptor *eventIndexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventMapping pathPattern:@"/events.json" keyPath:@"event" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:eventIndexResponseDescriptor];

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

- (void)setupPonyDebugger
{
    PDDebugger *debugger = [PDDebugger defaultInstance];
    [debugger autoConnect];
    [debugger enableViewHierarchyDebugging];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"MST"]];
    
    // Seed NSUserDefaults defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaultsDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SFUserDefaults" ofType:@"plist"]];
    [defaults registerDefaults:defaultsDictionary];
    
    [self setupRestKitWithBaseURL:[NSURL URLWithString:@"http://stanley-film.herokuapp.com"]];
    
#if defined(DEBUG)
    [self setupPonyDebugger];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.navigationPaneViewController = [[MSNavigationPaneViewController alloc] init];
    self.navigationPaneViewController.openDirection = MSNavigationPaneOpenDirectionTop;
    self.navigationPaneViewController.paneViewSlideOffAnimationEnabled = NO;
    self.navigationPaneViewController.openStateRevealWidth = ((44.0 * SFPaneTypeCount) + 20.0);
    self.navigationPaneViewController.appearanceType = MSNavigationPaneAppearanceTypeFade;
    [self.navigationPaneViewController.touchForwardingClasses addObject:SVSegmentedControl.class];
    
    SFMasterViewController *masterViewController = [[SFMasterViewController alloc] initWithNibName:nil bundle:nil];
    masterViewController.navigationPaneViewController = self.navigationPaneViewController;
    self.navigationPaneViewController.masterViewController = masterViewController;
    
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = self.navigationPaneViewController;
    [self.window makeKeyAndVisible];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SFUserDefaultsFirstLaunch]) {
        SFSplashViewController *splashViewController = [[SFSplashViewController alloc] initWithNibName:nil bundle:nil];
        [masterViewController presentViewController:splashViewController animated:NO completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SFUserDefaultsFirstLaunch];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/films.json" parameters:nil success:nil failure:nil];
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/events.json" parameters:nil success:nil failure:nil];
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/locations.json" parameters:nil success:nil failure:nil];
    }
    
    // Needs to be last in application:didFinishLaunchingWithOptions:
    [Crashlytics startWithAPIKey:@"071b8aadee1ba1cd89ac579557101520980223ca"];
    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait);
}

@end

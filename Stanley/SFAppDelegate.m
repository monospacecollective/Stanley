//
//  SFAppDelegate.m
//  Stanley
//
//  Created by Eric Horacek on 2/11/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFAppDelegate.h"
#import "SFFilm.h"
#import "SFFilmsViewController.h"
#import "SFNavigationBar.h"
#import "SFStyleManager.h"
#import "SFMasterViewController.h"
#import "SFSplashViewController.h"
#import "SFNoContentBackgroundView.h"

@interface SFAppDelegate ()

- (void)setupSocialKit;
- (void)setupRestKitWithBaseURL:(NSURL *)baseURL;
- (void)setupPonyDebugger;

@end

@implementation SFAppDelegate

- (void)setupSocialKit
{
    [[MSSocialKitManager sharedManager] configureStorage];
    
    [MSSocialKitManager sharedManager].twitterQuery = @"FROM:stanleyfilmfest OR YeahItsCreepy";
    [MSSocialKitManager sharedManager].instagramQuery = @"YeahItsCreepy";
    
    [MSSocialKitManager sharedManager].defaultTwitterComposeText = @"#yeahitscreepy";
    [MSSocialKitManager sharedManager].defaultInstagramCaptionText = @"#yeahitscreepy";
    
    SFNoContentBackgroundView *twitterPlaceholderView = [[SFNoContentBackgroundView alloc] init];
    twitterPlaceholderView.title.text = @"NO TWEETS";
    twitterPlaceholderView.icon.text = @"\U0001F4AC";
    twitterPlaceholderView.subtitle.text = @"Tweets about the Stanley Film Festival are currently not available. Check back later.";
    [MSSocialKitManager sharedManager].twitterPlaceholderView = twitterPlaceholderView;
    
    SFNoContentBackgroundView *instagramPlaceholderView = [[SFNoContentBackgroundView alloc] init];
    instagramPlaceholderView.title.text = @"NO PHOTOS";
    instagramPlaceholderView.icon.text = @"\U0001F304";
    instagramPlaceholderView.subtitle.text = @"Instagram photos of the Stanley Film Festival are currently not available. Check back later.";
    [MSSocialKitManager sharedManager].instagramPlaceholderView = instagramPlaceholderView;
}

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
    [filmMapping addAttributeMappingsFromArray:@[ @"name", @"synposis", @"language", @"runtime", @"rating", @"filmography", @"country", @"year" ]];
    [filmMapping addAttributeMappingsFromDictionary:@{ @"id" : @"remoteID", @"description" : @"detail", @"feature_image" : @"featureImage", @"print_source" : @"printSource", @"available_datetime" : @"available", @"ticket_url" : @"ticketURL", @"trailer_url" : @"trailerURL" }];
    
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
    
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelOff);
    RKLogConfigureByName("RestKit/CoreData", RKLogLevelOff);
    RKLogConfigureByName("RestKit/Network", RKLogLevelOff);
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
    
    [self setupSocialKit];
    
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
        splashViewController.shouldAutoplayTrailer = YES;
        
        [masterViewController presentViewController:splashViewController animated:NO completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SFUserDefaultsFirstLaunch];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Fetch all objects at first launch
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/films.json" parameters:nil success:nil failure:nil];
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/events.json" parameters:nil success:nil failure:nil];
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/locations.json" parameters:nil success:nil failure:nil];
    }
    
    // Needs to be last in application:didFinishLaunchingWithOptions:
    [Crashlytics startWithAPIKey:@"071b8aadee1ba1cd89ac579557101520980223ca"];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Reload currently visible pane's data
    if ([self.navigationPaneViewController.paneViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)self.navigationPaneViewController.paneViewController;
        if ([navigationController viewControllers].count) {
            UIViewController *rootViewController = [navigationController viewControllers][0];
            if ([rootViewController respondsToSelector:@selector(reloadData)]) {
                [rootViewController performSelector:@selector(reloadData)];
            }
        }
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

+ (SFAppDelegate *)sharedAppDelegate
{
    return (SFAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end

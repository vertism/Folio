//
//  UntitledAppDelegate.m
//  Untitled
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import "FolioAppDelegate.h"

@implementation FolioAppDelegate

@synthesize window;

static UITabBarItem *tbCollections;
static UITabBarItem *tbRecent;
static UITabBarItem *tbTags;
static UITabBarItem *tbAddItem;

static Collections *collections;
static Recent *recent;
static AddItem *addItem;
static Tags *tags;

static UINavigationController *navController;
static FoTabBarController *tabController;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	tbCollections = [[UITabBarItem alloc] initWithTitle:@"Collections" image:[UIImage imageNamed:@"collection.png"] tag:0];
	tbRecent = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:1];
	tbTags = [[UITabBarItem alloc] initWithTitle:@"Tags" image:[UIImage imageNamed:@"tags.png"] tag:2];
	tbAddItem = [[UITabBarItem alloc] initWithTitle:@"Add/Edit" image:[UIImage imageNamed:@"add.png"] tag:3];
	
	collections = [[Collections alloc] init];
	recent = [[Recent alloc] init];
	tags = [[Tags alloc] init];
	addItem = [[AddItem alloc] init];
	
	navController = [[UINavigationController alloc] initWithRootViewController:collections];
	tabController = [[FoTabBarController alloc] init];
	
    [window addSubview:navController.view];
	[window makeKeyAndVisible];
}

+ (UINavigationController*)NavController
{
	return navController;
}

+ (FoTabBarController*)TabController
{
	return tabController;
}

+ (Recent*)Recent
{
	return recent;
}

+ (AddItem*)AddItem
{
	return addItem;
}

+ (Collections*)Collections
{
	return collections;
}

+ (Tags*)Tags
{
	return tags;
}

+ (UITabBarItem*)TabRecent
{
	return tbRecent;
}

+ (UITabBarItem*)TabAddItem
{
	return tbAddItem;
}

+ (UITabBarItem*)TabCollections
{
	return tbCollections;
}

+ (UITabBarItem*)TabTags
{
	return tbTags;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Folio.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//abort();
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

@end


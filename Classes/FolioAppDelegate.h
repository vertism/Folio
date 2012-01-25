//
//  FolioAppDelegate.h
//  Folio
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoTabBarController.h"
#import "Collections.h"
#import "Recent.h"
#import "Tags.h"
#import "AddItem.h"


@interface FolioAppDelegate : NSObject <UIApplicationDelegate> 
{
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (NSString *)applicationDocumentsDirectory;
+ (FoTabBarController*)TabController;
+ (UINavigationController*)NavController;
+ (Recent*)Recent;
+ (AddItem*)AddItem;
+ (Collections*)Collections;
+ (Tags*)Tags;
+ (UITabBarItem*)TabRecent;
+ (UITabBarItem*)TabAddItem;
+ (UITabBarItem*)TabCollections;
+ (UITabBarItem*)TabTags;

@end

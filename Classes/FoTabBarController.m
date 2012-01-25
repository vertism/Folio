//
//  FoTabBarController.m
//  Folio
//
//  Created by Pep on 18/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import "FoTabBarController.h"
#import "FolioAppDelegate.h"

@implementation FoTabBarController

- (id)init
{
	[super init];
	return self;
}

- (NSArray*)Items
{
	return [[NSArray alloc] initWithObjects:FolioAppDelegate.TabCollections, FolioAppDelegate.TabRecent, FolioAppDelegate.TabTags, FolioAppDelegate.TabAddItem, nil];
}

#pragma mark -
#pragma mark TabBarDelegate

- (void)tabBar:(UITabBar *)myTabBar didSelectItem:(UITabBarItem *)item
{
	[self tabBar:myTabBar didSelectItem:item didPressTab:YES];
}

- (void)tabBar:(UITabBar *)myTabBar didSelectItem:(UITabBarItem *)item didPressTab:(BOOL)tab
{
	UINavigationController *myNav = FolioAppDelegate.NavController;
	myNav.viewControllers = nil;
	
	if (item == FolioAppDelegate.TabAddItem)
	{
		if (tab)
		{
			[FolioAppDelegate AddItem].selectedCollection = nil;
			[FolioAppDelegate AddItem].selectedItem = nil;
			[FolioAppDelegate AddItem].selectedTag = nil;
		}
		[myNav pushViewController:FolioAppDelegate.AddItem animated:NO];
	}
	else if (item == FolioAppDelegate.TabRecent)
	{
		if (tab)
		{
			[FolioAppDelegate Recent].selectedCollection = nil;
		}
		[myNav pushViewController:FolioAppDelegate.Recent animated:NO];
	}
	else if (item == FolioAppDelegate.TabCollections)
	{
		[myNav pushViewController:FolioAppDelegate.Collections animated:NO];
	}
	else if (item == FolioAppDelegate.TabTags)
	{
		[myNav pushViewController:FolioAppDelegate.Tags animated:NO];
	}
}

- (void)GoTo:(UITabBarItem*)tab
{
	[self tabBar:nil didSelectItem:tab didPressTab:NO];
}


@end

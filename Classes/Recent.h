//
//  Recent.h
//  Untitled
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Collection;

@interface Recent : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
	UITableView *tableView;
	UITabBar *tabBar;
	NSMutableArray *items;
	NSManagedObjectContext *context;
	
	Collection *selectedCollection;
}

@property (retain) Collection *selectedCollection;

- (void)loadItems:(NSString*)searchString;

@end

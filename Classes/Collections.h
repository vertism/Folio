//
//  Collections.h
//  Untitled
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Collections : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
	UITableView *tableView;
	UITabBar *tabBar;
	NSManagedObjectContext *context;
	
	NSMutableArray *collections;
}

- (void)loadItems;

@end

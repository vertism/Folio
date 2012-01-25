//
//  CollectionItems.h
//  Folio
//
//  Created by Pep on 22/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Collection;

@interface CollectionItems : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
	UITableView *tableView;
	UITabBar *tabBar;
	NSManagedObjectContext *context;
	
	Collection *selectedCollection;
	NSArray *items;
}

@property (retain) Collection *selectedCollection;

- (void)loadItems;

@end

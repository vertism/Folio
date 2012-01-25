//
//  TagItems.h
//  Folio
//
//  Created by Pep on 30/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tag;

@interface TagItems : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UITabBar *tabBar;
	NSManagedObjectContext *context;
	NSArray *items;
	Tag *selectedTag;
}

@property (retain) Tag *selectedTag;

- (void)loadItems;

@end

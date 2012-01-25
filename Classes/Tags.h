//
//  Tags.h
//  Folio
//
//  Created by Pep on 30/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tags : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> 
{
	UITableView *tableView;
	UITabBar *tabBar;
	NSMutableArray *tags;
	NSManagedObjectContext *context;
}

- (void)loadItems:(NSString*)searchString;

@end

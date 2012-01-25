//
//  Recent.m
//  Untitled
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import "Recent.h"
#import "Item.h"
#import "Collection.h"
#import "Picture.h"
#import "Tag.h"
#import "FolioAppDelegate.h"

#define CELLHEIGHT 75

@implementation Recent

@synthesize selectedCollection;

- (void)loadView 
{
    [super loadView];

    if (context == nil) 
	{ 
        context = [(FolioAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 372) style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [searchBar sizeToFit];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search";
    tableView.tableHeaderView = searchBar;
	
    UISearchDisplayController *searchDC = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	
    // The above assigns self.searchDisplayController, but without retaining.
    // Force the read-only property to be set and retained. 
    [self performSelector:@selector(setSearchDisplayController:) withObject:searchDC];
	
    searchDC.delegate = self;
    searchDC.searchResultsDataSource = self;
    searchDC.searchResultsDelegate = self;
	
    [searchBar release];
    [searchDC release];
	
	tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 372, 320, 44)];
	tabBar.delegate = FolioAppDelegate.TabController;
	
	[self.view addSubview:tableView];
	[self.view addSubview:tabBar];
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	if (selectedCollection)
	{
		self.navigationItem.title = [NSString stringWithFormat:@"Add To %@", selectedCollection.Name];
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
		[self.navigationItem setLeftBarButtonItem:cancelButton];
		[self.navigationItem setRightBarButtonItem:saveButton];
		[cancelButton release];
		[saveButton release];
	}
	else
	{
		self.navigationItem.title = @"Recent";
		[self.navigationItem setLeftBarButtonItem:nil];
		[self.navigationItem setRightBarButtonItem:nil];
	}
	
	[tabBar setItems:FolioAppDelegate.TabController.Items];
	tabBar.selectedItem = FolioAppDelegate.TabRecent;
	
	[self loadItems:@""];
	[tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[selectedCollection release];
	selectedCollection = nil;
}

- (void)loadItems:(NSString*)searchString
{	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Item" inManagedObjectContext:context];
	
	if (![searchString isEqualToString:@""])
	{
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"primaryTag.tagName CONTAINS[cd] %@", searchString];
		[fetchRequest setPredicate:pred];
	}
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateTime" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
	if (items != nil)
		[items release];
    items = [[context executeFetchRequest:fetchRequest error:&error] retain];
    [fetchRequest release];
}

- (void)save
{
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	[context rollback];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table view methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self loadItems:searchText];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return items.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tabView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	for (UIView *view in cell.contentView.subviews) 
	{ 
		[view removeFromSuperview]; 
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	@try 
	{
		Item *currentItem = [items objectAtIndex:indexPath.row];
		
		//image
		NSArray *aPrimaryPicture = [currentItem valueForKey:@"primaryPicture"];
		if ([aPrimaryPicture count] > 0)
		{
			Picture *primaryPicture = [aPrimaryPicture objectAtIndex:0];
			UIImage *pic = [UIImage imageWithData:primaryPicture.cellView];
			cell.imageView.image = pic;
		}
		else
		{
			cell.imageView.image = nil;
		}
		
		//Date
		NSDateFormatter *formatter;
		NSString *dateString;
		
		formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterFullStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		
		dateString = [formatter stringFromDate:currentItem.updateTime];
		
		[formatter release];
		
		int labelsMargin = CELLHEIGHT + 10;
		
		UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(labelsMargin, 2, 250, 16)];
		lblDate.font = [UIFont systemFontOfSize:11];
		lblDate.text = dateString;
		lblDate.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
		lblDate.highlightedTextColor = [UIColor whiteColor];
		[cell.contentView addSubview:lblDate];
		[lblDate release];
		
		int labelWidth = 250;
		
		//title
		UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(labelsMargin, 19, labelWidth, 20)];
		lblTitle.font = [UIFont boldSystemFontOfSize:18];
		lblTitle.textColor = [UIColor blackColor];
		
		if (selectedCollection)
		{
			lblTitle.textColor = [UIColor grayColor];
			for (Collection *col in [currentItem.collections allObjects])
			{
				if (col == selectedCollection)
				{
					lblTitle.textColor = [UIColor grayColor];
					break;
				}
			}
		}
		
		lblTitle.highlightedTextColor = [UIColor whiteColor];
		lblTitle.text = currentItem.primaryTag.tagName;
		[cell.contentView addSubview:lblTitle];
		[lblTitle release];
		
		//tags
		NSMutableString *tagString = [[NSMutableString alloc] initWithString:@""];
		
		for (Tag *t in currentItem.tags)
		{
			if (t != currentItem.primaryTag)
			{
				if (![tagString isEqualToString:@""])
					[tagString appendString:@"   "];
				[tagString appendString:t.tagName];
			}
		}
		
		UILabel *lblTags = [[UILabel alloc] initWithFrame:CGRectMake(labelsMargin, 40, labelWidth, 30)];
		lblTags.font = [UIFont systemFontOfSize:13];
		lblTags.textColor = [UIColor grayColor];
		lblTags.highlightedTextColor = [UIColor whiteColor];
		lblTags.numberOfLines = 2;
		lblTags.lineBreakMode = UILineBreakModeWordWrap;
		lblTags.text = tagString;
		
		CGSize stringSize = [tagString sizeWithFont:lblTags.font constrainedToSize:lblTags.frame.size lineBreakMode:lblTags.lineBreakMode];
		CGRect lblTagsFrame = CGRectMake(labelsMargin, 40, labelWidth, stringSize.height);
		lblTags.frame = lblTagsFrame;
		
		[cell.contentView addSubview:lblTags];
		[lblTags release];
	}
	@catch (NSException * e) 
	{
		NSLog(@"Failed to get Item");
	}
	@finally 
	{
		return cell;
	}
}


- (void)tableView:(UITableView *)oTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Item *chosenItem = [[items objectAtIndex:indexPath.row] retain];
	BOOL inCollection = NO;
	
	if (selectedCollection)
	{
		for (Collection *col in [chosenItem.collections allObjects])
		{
			if (col == selectedCollection)
			{
				inCollection = YES;
			}
		}
		if (inCollection)
		{
			[chosenItem removeCollectionsObject:selectedCollection];
		}
		else
		{
 			[chosenItem addCollectionsObject:selectedCollection];
		}
		[tableView reloadData];
	}
	else
	{
		AddItem *addItem = [FolioAppDelegate AddItem];
		addItem.selectedItem = chosenItem;
		[self.navigationController pushViewController:addItem animated:YES];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/



// Override to support editing the table view.
- (void)tableView:(UITableView *)tabView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		NSError *error;
		[context deleteObject:[items objectAtIndex:indexPath.row]];
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}
		[self loadItems:@""];
        [tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}

#pragma mark -

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 75;
}


- (void)dealloc {
    [super dealloc];
}


@end


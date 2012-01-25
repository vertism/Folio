    //
//  Tags.m
//  Folio
//
//  Created by Pep on 30/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import "Tags.h"
#import "FolioAppDelegate.h"
#import "Tag.h"
#import "TagItems.h"

@implementation Tags

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
	self.navigationItem.title = @"Tags";
	[tabBar setItems:FolioAppDelegate.TabController.Items];
	tabBar.selectedItem = FolioAppDelegate.TabTags;
	
	[self loadItems:@""];
	[tableView reloadData];
}

- (void)loadItems:(NSString*)searchString
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Tag" inManagedObjectContext:context];
	
	NSPredicate *pred;
	if (![searchString isEqualToString:@""])
	{
		pred = [NSPredicate predicateWithFormat:@"items.@count > 0 AND tagName contains[cd] %@", searchString];
	}
	else
	{
		pred = [NSPredicate predicateWithFormat:@"items.@count > 0"];
	}
	[fetchRequest setPredicate:pred];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagName" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
	
	if (tags != nil)
		[tags release];
    tags = [[context executeFetchRequest:fetchRequest error:&error] retain];
    [fetchRequest release];
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self loadItems:searchText];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return tags.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)oTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [oTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
	Tag *tag = [tags objectAtIndex:indexPath.row];
    cell.textLabel.text = tag.tagName;
	
	UILabel *accessory = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	accessory.text = [NSString stringWithFormat:@"%d", [tag.items count]];
	accessory.font = [UIFont boldSystemFontOfSize:28];
	accessory.textColor = [UIColor grayColor];
	cell.accessoryView = accessory;
	[accessory release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	TagItems *tagItems = [[TagItems alloc] init];
	tagItems.selectedTag = [[tags objectAtIndex:indexPath.row] retain];
	[self.navigationController pushViewController:tagItems animated:YES];
}


- (void)tableView:(UITableView *)tabView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		NSError *error;
		[context deleteObject:[tags objectAtIndex:indexPath.row]];
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}
		[self loadItems:@""];
        [tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}

/*- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)oTableView
{
	return [NSArray arrayWithObjects:UITableViewIndexSearch, @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	int closest = 0;
	
	const char *cIndex = [[title lowercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
	
	for (int i = 0; i < [tags count]; i++)
	{
		Tag *currentTag = [tags objectAtIndex:i];
		const char *cFirstChar = [[[currentTag.tagName substringToIndex:1] lowercaseString] cStringUsingEncoding:NSASCIIStringEncoding];
		if (cIndex == cFirstChar)
		{
			closest = i;
			break;
		}
		else
		{
			if (cFirstChar < cIndex)
			{
				closest = i;
			}
		}
	}
	
	return closest;
}*/

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


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


- (void)dealloc {
    [super dealloc];
}


@end

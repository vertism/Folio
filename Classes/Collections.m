//
//  Collections.m
//  Untitled
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import "Collections.h"
#import "FolioAppDelegate.h"
#import "AddCollection.h"
#import "Collection.h"
#import "CollectionItems.h"

@implementation Collections

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
	
	tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 372, 320, 44)];
	tabBar.delegate = FolioAppDelegate.TabController;
	
	[self.view addSubview:tableView];
	[self.view addSubview:tabBar];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
	[self.navigationItem setRightBarButtonItem:addButton];
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	self.navigationItem.title = @"Collections";
	[tabBar setItems:FolioAppDelegate.TabController.Items];
	tabBar.selectedItem = FolioAppDelegate.TabCollections;
	
	[self loadItems];
	[tableView reloadData];
}

- (void)loadItems
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Collection" inManagedObjectContext:context];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    collections = [[context executeFetchRequest:fetchRequest error:&error] retain];
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

- (void)add
{
	AddCollection *addCol = [[AddCollection alloc] init];
	[addCol setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self.tabBarController.modalViewController presentModalViewController:addCol animated:YES];
	[self presentModalViewController:addCol animated:YES];
}
	 

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return collections.count;
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
    
	Collection *col = [collections objectAtIndex:indexPath.row];
    cell.textLabel.text = col.Name;
	
	UILabel *accessory = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	accessory.text = [NSString stringWithFormat:@"%d", [col.items count]];
	accessory.font = [UIFont boldSystemFontOfSize:28];
	accessory.textColor = [UIColor grayColor];
	cell.accessoryView = accessory;
	[accessory release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	CollectionItems *colItems = [[CollectionItems alloc] init];
	colItems.selectedCollection = [[collections objectAtIndex:indexPath.row] retain];
	[self.navigationController pushViewController:colItems animated:YES];
}


- (void)tableView:(UITableView *)tabView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		NSError *error;
		[context deleteObject:[collections objectAtIndex:indexPath.row]];
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}
		[self loadItems];
        [tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}

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


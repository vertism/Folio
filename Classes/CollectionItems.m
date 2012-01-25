//
//  CollectionItems.m
//  Folio
//
//  Created by Pep on 22/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import "CollectionItems.h"
#import "FolioAppDelegate.h"
#import "Collection.h"
#import "Item.h"
#import "Tag.h"
#import "Picture.h"

#define CELLHEIGHT 75

@implementation CollectionItems

@synthesize selectedCollection;

- (void)loadView 
{
    [super loadView];
	
    if (context == nil) 
	{ 
        context = [(FolioAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 392) style:UITableViewStylePlain];
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
	self.navigationItem.title = selectedCollection.Name;
	[tabBar setItems:FolioAppDelegate.TabController.Items];
	tabBar.selectedItem = FolioAppDelegate.TabCollections;

	[self loadItems];
	[tableView reloadData];
}

- (void)loadItems
{
	[items release];
	NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"primaryTag.tagName" ascending:YES]];
	items = [[NSArray alloc] initWithArray:[[selectedCollection.items allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
}

- (void)add
{
	UIActionSheet *addChoice = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add New", @"Add Existing", nil];
	[addChoice showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
	[addChoice release];
}

#pragma mark -
#pragma mark Action Sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0://new
		{
			AddItem *addItem = [FolioAppDelegate AddItem];
			addItem.selectedItem = nil;
			addItem.selectedCollection = selectedCollection;
			[self.navigationController pushViewController:addItem animated:YES];
		}
			break;
			
		case 1://existing
		{
			Recent *recent = [FolioAppDelegate Recent];
			recent.selectedCollection = selectedCollection;
			[self.navigationController pushViewController:recent animated:YES];
		}
			break;
	}
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return items.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)oTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [oTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    Item *currentItem = [items objectAtIndex:indexPath.row];
	
	//image
	NSArray *aPrimaryPicture = [currentItem valueForKey:@"primaryPicture"];
	if ([aPrimaryPicture count] > 0)
	{
		Picture *primaryPicture = [aPrimaryPicture objectAtIndex:0];
		UIImage *pic = [UIImage imageWithData:primaryPicture.cellView];
		cell.imageView.image = pic;
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	AddItem *addItem = [FolioAppDelegate AddItem];
	addItem.selectedItem = [[items objectAtIndex:indexPath.row] retain];
	addItem.selectedCollection = [selectedCollection retain];
	[self.navigationController pushViewController:addItem animated:YES];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tabView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		Item *currentItem = [items objectAtIndex:indexPath.row];
		[selectedCollection removeItemsObject:currentItem];
		
		NSError *error;
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}
		
		[self loadItems];
		[tableView reloadData];
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return CELLHEIGHT;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end


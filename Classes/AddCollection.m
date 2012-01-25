//
//  AddCollection.m
//  Folio
//
//  Created by Pep on 19/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AddCollection.h"
#import "Collection.h"
#import "FolioAppDelegate.h"

@implementation AddCollection


#pragma mark -
#pragma mark Initialization


- (void)loadView
{
	[super loadView];
	
	if (!context) 
	{ 
        context = [(FolioAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[self.view addSubview:navBar];
	
	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Add Collection"];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)]; 
	[navItem setRightBarButtonItem:rightButton];
	[navItem setLeftBarButtonItem:leftButton];
	[navBar pushNavigationItem:navItem animated:NO];
	[navItem release];
	
	textBox = [[UITextField alloc] initWithFrame:CGRectMake(20, 64, 280, 30)];
	textBox.placeholder = @"Collection Name";
	textBox.borderStyle = UITextBorderStyleRoundedRect;
	//textBox.layer.cornerRadius = 10;
	textBox.font = [UIFont systemFontOfSize:20];
	textBox.returnKeyType = UIReturnKeyDone;
	textBox.delegate = self;
	[textBox becomeFirstResponder];
	[self.view addSubview:textBox];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
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

- (void)cancel
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)save
{
	Collection *col = [NSEntityDescription insertNewObjectForEntityForName: @"Collection"
												 inManagedObjectContext: context];
	col.Name = textBox.text;

	NSError *error;
	if (![context save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
	[self cancel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString *trimmedString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	if (![trimmedString isEqualToString:@""])
	{
		[self save];
		return YES;
	}
	else
	{
		return NO;
	}
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


- (void)dealloc 
{
    [super dealloc];
}


@end


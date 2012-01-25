//
//  AddItem.m
//  Folio
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import "AddItem.h"
#import <QuartzCore/QuartzCore.h>
#import "FolioAppDelegate.h"
#import "Item.h"
#import "Collection.h"
#import "Tag.h"
#import "Picture.h"

#define radians( degrees ) ( degrees * M_PI / 180 )
#define NEWTAG -1

@implementation AddItem

@synthesize selectedItem, selectedCollection, selectedTag;

const int MARGIN = 10;
const int LABELFONTSIZE = 16;

NSTimeInterval touchStartTime;

- (id)init
{
	tagRects = [[NSMutableArray alloc] init];
	tags = [[NSMutableArray alloc] init];
	currentIndex = NEWTAG;
	bReload = YES;
	
	if (!context) 
	{ 
        context = [(FolioAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
	return self;
}

- (void)loadView 
{
	[super loadView];
	
	//self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	UIImageView *backGround = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	backGround.image = [UIImage imageNamed:@"pinboard.jpg"];
	[self.view addSubview:backGround];
	[backGround release];

	UIView *photoSpace = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
	photoSpace.tag = ControlTypeNewPhoto;
	//photoSpace.alpha = 0.8;
	photoSpace.backgroundColor = [UIColor blackColor];
	photoSpace.layer.cornerRadius = 10;
	UILabel *lblPhoto = [[UILabel alloc] initWithFrame:CGRectMake(10, 62, 50, 20)];
	lblPhoto.font = [UIFont systemFontOfSize:12];
	lblPhoto.textAlignment = UITextAlignmentCenter;
	lblPhoto.tag = ControlTypeLabel1;
	lblPhoto.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[lblPhoto setText:@"Camera"];
	[self.view addSubview:lblPhoto];
	[lblPhoto release];
	[self.view addSubview:photoSpace];
	[photoSpace release];
	
	imagePlaceholder = [[UIView alloc] initWithFrame:CGRectMake(85, 10, 150, 130)];
	imagePlaceholder.tag = ControlTypeImagePlaceholder;
	imagePlaceholder.backgroundColor = [UIColor blackColor];
	imagePlaceholder.userInteractionEnabled = YES;
	CALayer * l = [imagePlaceholder layer];
	[l setMasksToBounds:YES];
	[l setCornerRadius:10.0];
	[self.view addSubview:imagePlaceholder];
	
	UIView *imageSpace = [[UIView alloc] initWithFrame:CGRectMake(260, 10, 50, 50)];
	imageSpace.tag = ControlTypeExistingPhoto;
	//imageSpace.alpha = 0.8;
	imageSpace.backgroundColor = [UIColor blackColor];
	imageSpace.layer.cornerRadius = 10;
	UILabel *lblImage = [[UILabel alloc] initWithFrame:CGRectMake(260, 62, 50, 20)];
	lblImage.font = [UIFont systemFontOfSize:12];
	lblImage.textAlignment = UITextAlignmentCenter;
	lblImage.tag = ControlTypeLabel2;
	[lblImage setText:@"Photos"];
	lblImage.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[self.view addSubview:lblImage];
	[lblImage release];
	[self.view addSubview:imageSpace];
	[imageSpace release];
	
	textInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 155, 220, 30)];
	textInput.clearButtonMode = UITextFieldViewModeAlways;
	textInput.borderStyle = UITextBorderStyleRoundedRect;
	textInput.backgroundColor = [UIColor clearColor];
	textInput.keyboardAppearance = UIKeyboardAppearanceAlert;
	textInput.delegate = self;
	[self.view addSubview:textInput];
	
	UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[saveButton setTitle:@"Save All" forState:UIControlStateNormal];
	saveButton.frame = CGRectMake(240, 157, 70, 25);
	[saveButton addTarget:self action:@selector(Save) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:saveButton];
	
	tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 372, 320, 44)];
	tabBar.delegate = FolioAppDelegate.TabController;
	[self.view addSubview:tabBar];
}

-(void)viewWillAppear:(BOOL)animated
{
	if (bReload)
	{
		[self Reset];
		if (selectedItem)
		{
			self.navigationItem.title = selectedItem.primaryTag.tagName;
			for (Picture *pic in selectedItem.pictures)
			{
				[self showThumbnailFromData:pic.thumbnail];
				break;
			}
			
			int iCount = 0;
			for (Tag *tag in selectedItem.tags)
			{
				if (selectedItem.primaryTag == tag)
					primaryIndex = iCount;
				[tags addObject:tag.tagName];
				iCount++;
			}
			[self ArrangeTags];
		}
		else
		{
			self.navigationItem.title = @"";
		}
	}
	else
		bReload = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[context rollback];
}

- (void)Reset
{
	textInput.text = @"";
	currentIndex = NEWTAG;
	primaryIndex = 0;
	
	[self RemoveTags];
	[tags removeAllObjects];
	
	for (UIView *view in imagePlaceholder.subviews) 
	{ 
		[view removeFromSuperview]; 
	}
	
	[imgData release];
	[thumbData release];
	[cellData release];
	
	[textInput resignFirstResponder];
	
	[tabBar setItems:FolioAppDelegate.TabController.Items];
	tabBar.selectedItem = FolioAppDelegate.TabAddItem;
}

- (void)showThumbnailFromData:(NSData*)picData
{
	UIImage *thumbnail = [UIImage imageWithData:picData];
	[self showThumbnail:thumbnail];
}

- (void)showThumbnail:(UIImage*)thumbnail
{
	UIImageView *imgView = [[UIImageView alloc] initWithImage:thumbnail];
	int xOrigin = (imagePlaceholder.frame.size.width - imgView.image.size.width) / 2;
	int YOrigin = (imagePlaceholder.frame.size.height - imgView.image.size.height) / 2;
	imgView.frame = CGRectMake(xOrigin, YOrigin, imgView.image.size.width, imgView.image.size.height);

	for (UIView *view in imagePlaceholder.subviews) 
	{ 
		[view removeFromSuperview]; 
	}
	
	[imagePlaceholder addSubview:imgView];
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (currentIndex == NEWTAG)
	{
		[self AddNewTag:textField.text];
	}
	else
	{
		//Remove or modify text in array
		if ([textField.text isEqualToString:@""])
		{
			[tags removeObjectAtIndex:currentIndex];
			currentIndex = NEWTAG;
		}
		else
			[tags replaceObjectAtIndex:currentIndex withObject:textField.text];
		
		//Re-arrange tag labels
		[self ArrangeTags];
	}
	
	textField.text = @"";
	currentIndex = NEWTAG;
	
	return YES;
}

- (void)AddNewTag:(NSString*)tag
{
	if (tag)
	{
		NSString *modTag = [tag stringByReplacingOccurrencesOfString:@" " withString:@""];
		if (![modTag isEqualToString:@""])
		{
			if ([tags count] == 0)
			{
				primaryIndex = 0;
				[self DisplayTag:tag isSelected:NO isPrimary:YES];
			}
			else
			{
				[self DisplayTag:tag isSelected:NO isPrimary:NO];
			}
				
			[tags addObject:tag];
		}
	}
}

- (void)RemoveTags
{
	for (UILabel *lbl in tagRects)
	{
		[lbl removeFromSuperview];
	}
	[tagRects removeAllObjects];
}

- (void)ArrangeTags
{
	[self RemoveTags];
	
	for (int i = 0; i < [tags count]; i++)
	{
		[self DisplayTag:[tags objectAtIndex:i] isSelected:(i == currentIndex) isPrimary:(i == primaryIndex)];
	}
}

- (void)DisplayTag:(NSString*)text isSelected:(BOOL)selected isPrimary:(BOOL)primary
{
	UIFont *font;
	if (selected)
		font = [UIFont boldSystemFontOfSize:LABELFONTSIZE];
	else
		font = [UIFont systemFontOfSize:LABELFONTSIZE];

	CGSize textSize = [text sizeWithFont:font];
	CGRect tagRect;
	
	if ([tagRects count] == 0)
		tagRect = CGRectMake(MARGIN, 195, textSize.width, textSize.height);
	else
	{
		CGRect lastRect = [[tagRects lastObject] frame];
		if (lastRect.origin.x + lastRect.size.width + textSize.width + MARGIN < 300)
			tagRect = CGRectMake(lastRect.origin.x + lastRect.size.width + 10, lastRect.origin.y, textSize.width, textSize.height);
		else
			tagRect = CGRectMake(MARGIN, lastRect.origin.y + lastRect.size.height + MARGIN, textSize.width, textSize.height);
		//TODO: modify UILabel if too long for screen. Maybe reduce length and add ellipses
	}
	
	UILabel *tag = [[UILabel alloc] initWithFrame:tagRect];
	tag.font = font;
	tag.text = text;	
	[tag sizeToFit];
	
	tag.layer.cornerRadius = 5;
	
	if (primary)
	{
		self.navigationItem.title = text;
		tag.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
	}
	else
	{
		tag.backgroundColor = [UIColor colorWithRed:0.75 green:0.96 blue:0.98 alpha:1];
	}
	
	[self.view addSubview:tag];
	
	[tagRects addObject:tag];
	[tag release];
}

- (void)Save
{		
	if (currentIndex == NEWTAG)
	{ 
		[self AddNewTag:textInput.text];
	}
	
	if ([tags count] > 0)
	{
		Item *saveItem = selectedItem;
		
		if (!saveItem)
		{
			saveItem = [NSEntityDescription insertNewObjectForEntityForName: @"Item"
														 inManagedObjectContext: context];
		}
		
		[saveItem removeTags:saveItem.tags];

		if (selectedCollection)
		{
			[saveItem addCollectionsObject:selectedCollection];
		}
		
		saveItem.updateTime = [NSDate date];
		for (int i = 0; i < [tags count]; i++)
		{
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription 
										   entityForName:@"Tag" inManagedObjectContext:context];
			NSPredicate *pred = [NSPredicate predicateWithFormat:@"tagName = %@", [tags objectAtIndex:i]];
			[fetchRequest setEntity:entity];
			[fetchRequest setPredicate:pred];
			NSError *error = nil;
			NSArray *returnedTags = [context executeFetchRequest:fetchRequest error:&error];
			[fetchRequest release];
			
			Tag *newTag;
			
			if ([returnedTags count] == 0)
			{
				newTag = [NSEntityDescription
							   insertNewObjectForEntityForName:@"Tag" 
							   inManagedObjectContext:context];
				[newTag addItemsObject:saveItem];
				newTag.tagName = [tags objectAtIndex:i];
			}
			else
			{
				newTag = [returnedTags objectAtIndex:0];
			}
			[saveItem addTagsObject:newTag];
			
			if (i == primaryIndex)
				saveItem.primaryTag = newTag;
		}
		
		if (imgData)
		{
			Picture *newPicture = [NSEntityDescription
								   insertNewObjectForEntityForName:@"Picture" 
								   inManagedObjectContext:context];
			newPicture.image = [imgData retain];
			newPicture.dateAdded = [NSDate date];
			newPicture.thumbnail = [thumbData retain];
			newPicture.cellView = [cellData retain];
			newPicture.item = saveItem;
			newPicture.primary = [NSNumber numberWithInt:1];
			[saveItem addPicturesObject:newPicture];		
		}
		
		NSError *error;
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}
		
		[self Reset];
		
		if (selectedItem || selectedCollection || selectedTag)
			[self.navigationController popViewControllerAnimated:YES];
		else
			[[FolioAppDelegate TabController] GoTo:FolioAppDelegate.TabRecent];
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	
	for (int i = 0; i < [tagRects count]; i++)
	{
		CGRect rect = [[tagRects objectAtIndex:i] frame];
		if (CGRectContainsPoint(rect, touchLocation))
		{
			touchStartTime = [event timestamp];
			currentIndex = i;
			break;
		}
		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:self.view];
	
	BOOL keyboardOpen = [textInput isFirstResponder];
	[textInput resignFirstResponder];
	
	for (int i = 0; i < [tagRects count]; i++)
	{
		CGRect rect = [[tagRects objectAtIndex:i] frame];
		if (CGRectContainsPoint(rect, touchLocation))
		{
			//Is this where we started touching?
			if (currentIndex == i)
			{
				textInput.text = [tags objectAtIndex:i];
				if (([event timestamp] - touchStartTime) < 0.5)
				{
					[textInput becomeFirstResponder];
				}
				else
				{
					primaryIndex = i;
				}
				[self ArrangeTags];
			}
			else
				currentIndex = NEWTAG;
			
			return;
		}
	}
	
	if (!keyboardOpen)
	{
		currentIndex = NEWTAG;
		[self ArrangeTags];
	}
	
	switch (touch.view.tag)
	{
		case ControlTypeNewPhoto:
			[self ImagePicker:UIImagePickerControllerSourceTypeCamera];
			break;
			
		case ControlTypeExistingPhoto:
			[self ImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
			break;
			
		case ControlTypeImagePlaceholder:
		{
			if (selectedItem)
			{
				bReload = NO;
				UIImage *mainImage;
				for (Picture *pic in selectedItem.pictures)
				{
					mainImage = [UIImage imageWithData:pic.image];
					break;
				}
				
				UIViewController *imageController = [[UIViewController alloc] init];
				showImageView = [[UIImageView alloc] initWithImage:mainImage];
				showImageView.userInteractionEnabled = YES;
				UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
				scrollView.delegate = self;
				scrollView.contentSize = showImageView.image.size;
				scrollView.minimumZoomScale = 1;
				scrollView.maximumZoomScale = 3;
				scrollView.zoomScale = 1;
				imageController.view = scrollView;
				[scrollView addSubview:showImageView];
				imageController.title = selectedItem.primaryTag.tagName;
				[self.navigationController pushViewController:imageController animated:YES];
			}
			break;
		}
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return showImageView;
}

- (void)ImagePicker:(UIImagePickerControllerSourceType)source
{
	if ([UIImagePickerController isSourceTypeAvailable:source])
	{
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.sourceType = source;
		imagePicker.allowsEditing = YES;
		imagePicker.delegate = self;
		[imagePicker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self presentModalViewController:imagePicker animated:YES];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{	
	//TODO: show saving dialog
	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	
	int targetHeight = imagePlaceholder.frame.size.height;
	int targetWidth = imagePlaceholder.frame.size.width;
	double targetRatio = targetWidth / (targetHeight * 1.0);
	double sourceRatio = image.size.width / (image.size.height * 1.0);
	
	if (sourceRatio < targetRatio) //wider
	{
		targetWidth = image.size.width * (targetHeight / image.size.height);
	}
	else if (targetRatio < sourceRatio) //taller
	{
		targetHeight = image.size.height * (targetWidth / image.size.width);
	}
	
	UIImage *thumbNail = [self imageWithImage:image scaledToSize:CGSizeMake(targetWidth, targetHeight)];
	[self showThumbnail:thumbNail];
	
	targetWidth = 75;
	targetHeight = 75;
	
	if (image.size.height < image.size.width)
	{
		targetHeight = targetWidth / sourceRatio;
	}
	else if (image.size.width < image.size.height)
	{
		targetWidth = targetHeight * sourceRatio;
	}
	
	UIImage *cellView = [self imageWithImage:image scaledToSize:CGSizeMake(targetWidth, targetHeight)];
	
	imgData = [UIImagePNGRepresentation(image) retain];
	thumbData = [UIImagePNGRepresentation(thumbNail) retain];
	cellData = [UIImagePNGRepresentation(cellView) retain];

	bReload = NO;
	[self dismissModalViewControllerAnimated:YES];
}

- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)targetSize;
{
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
	
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
    if (bitmapInfo == kCGImageAlphaNone) 
	{
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
	
    CGContextRef bitmap;
	
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) 
	{
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
    } 
	else 
	{
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    }   
	
    if (sourceImage.imageOrientation == UIImageOrientationLeft) 
	{
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
    } 
	else if (sourceImage.imageOrientation == UIImageOrientationRight) 
	{
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
    } 
	else if (sourceImage.imageOrientation == UIImageOrientationUp) 
	{
        // NOTHING
    } 
	else if (sourceImage.imageOrientation == UIImageOrientationDown) 
	{
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
	
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
	
    CGContextRelease(bitmap);
    CGImageRelease(ref);
	
    return newImage; 
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
	[imgData release];
	[thumbData release];
	[textInput release];
}


@end

//
//  AddItem.h
//  Folio
//
//  Created by Andrew on 01/06/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@class Collection;
@class Tag;

typedef enum
{
	ControlTypeNewPhoto = 10,
	ControlTypeExistingPhoto,
	ControlTypeImagePlaceholder,
	ControlTypeLabel1,
	ControlTypeLabel2
}ControlType;

@interface AddItem : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITabBarDelegate, UIScrollViewDelegate> 
{
	Item *selectedItem;
	NSManagedObjectContext *context;
	UITabBar *tabBar;
	UIView *imagePlaceholder;
	UIImageView *showImageView;
	
	NSMutableArray *tagRects;
	NSMutableArray *tags;
	UITextField *textInput;
	int currentIndex;
	int primaryIndex;
	BOOL bReload;
	
	NSData *imgData;
	NSData *thumbData;
	NSData *cellData;
	
	Collection *selectedCollection;
	Tag *selectedTag;
}

@property (retain) Item *selectedItem;
@property (retain) Collection *selectedCollection;
@property (retain) Tag *selectedTag;

- (void)ImagePicker:(UIImagePickerControllerSourceType)source;
- (void)ArrangeTags;
- (void)DisplayTag:(NSString*)text isSelected:(BOOL)selected isPrimary:(BOOL)primary;
- (void)Reset;
- (void)AddNewTag:(NSString*)tag;
- (void)RemoveTags;
- (void)showThumbnailFromData:(NSData*)picData;
- (void)showThumbnail:(UIImage*)thumbnail;
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;

@end

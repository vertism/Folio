//
//  Picture.h
//  Folio
//
//  Created by Pep on 24/10/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Item;

@interface Picture :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * primary;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSData * cellView;
@property (nonatomic, retain) Item * item;

@end




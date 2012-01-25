//
//  Tag.h
//  Folio
//
//  Created by Pep on 24/10/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Item;

@interface Tag :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) NSSet* items;

@end


@interface Tag (CoreDataGeneratedAccessors)
- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end


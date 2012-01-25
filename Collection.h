//
//  Collection.h
//  Folio
//
//  Created by Pep on 24/10/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Item;

@interface Collection :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSSet* items;

@end


@interface Collection (CoreDataGeneratedAccessors)
- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end


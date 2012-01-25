//
//  Item.h
//  Folio
//
//  Created by Pep on 24/10/2010.
//  Copyright 2010 none. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Collection;
@class Picture;
@class Tag;

@interface Item :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSSet* collections;
@property (nonatomic, retain) NSSet* pictures;
@property (nonatomic, retain) Tag * primaryTag;
@property (nonatomic, retain) NSSet* tags;

@end


@interface Item (CoreDataGeneratedAccessors)
- (void)addCollectionsObject:(Collection *)value;
- (void)removeCollectionsObject:(Collection *)value;
- (void)addCollections:(NSSet *)value;
- (void)removeCollections:(NSSet *)value;

- (void)addPicturesObject:(Picture *)value;
- (void)removePicturesObject:(Picture *)value;
- (void)addPictures:(NSSet *)value;
- (void)removePictures:(NSSet *)value;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)value;
- (void)removeTags:(NSSet *)value;

@end


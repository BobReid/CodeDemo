//
//  CDPhotoDescription.h
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDFlickrManagedObject.h"

@class CDPhotoHandle;

@interface CDPhotoDescription : CDFlickrManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * farmId;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * originalSecret;
@property (nonatomic, retain) NSString * originalFormat;
@property (nonatomic, retain) CDPhotoHandle* thumbnailHandle;
@property (nonatomic, retain) CDPhotoHandle* largestHandle;
@property (nonatomic, retain) NSSet *handles;
@end

@interface CDPhotoDescription (CoreDataGeneratedAccessors)

- (void)addHandlesObject:(CDPhotoHandle *)value;
- (void)removeHandlesObject:(CDPhotoHandle *)value;
- (void)addHandles:(NSSet *)values;
- (void)removeHandles:(NSSet *)values;

+ (void)favouritePhotos:(void(^)(NSArray* photos, NSError* error))completion;
+ (void)searchForPhotosWithTerm:(NSString*)term page:(NSUInteger)page completion:(void(^)(NSArray* photos, NSError* error))completion;
- (CDPhotoDescription*)saveToFavourites;
- (void)deleteFromFavourites;

@end

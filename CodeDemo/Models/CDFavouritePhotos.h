//
//  CDFavouritePhotos.h
//  CodeDemo
//
//  Created by Bob Reid on 11/1/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDPhotoDescription.h"
#import "CDPhotoHandle.h"

static NSString *const CDFavouritePhotosLoaded      = @"CDFavouritePhotosLoaded";
static NSString *const CDFavouritePhotosUnloaded    = @"CDFavouritePhotosUnloaded";
static NSString *const CDFavouritePhotoAdded        = @"CDFavouritePhotoAdded";
static NSString *const CDFavouritePhotoRemoved      = @"CDFavouritePhotoRemoved";
static NSString *const CDFavouritePhotoRepositioned = @"CDFavouritePhotoRepositioned";
static NSString *const CDFavouritePhotoFromIndexKey = @"CDFavouritePhotoRepositioned";
static NSString *const CDFavouritePhotoToIndexKey   = @"CDFavouritePhotoRepositioned";


@interface CDFavouritePhotos : NSObject

+ (CDFavouritePhotos*)album;

- (void)loadPhotos;
- (void)unloadPhotos;

- (NSUInteger)count;
- (CDPhotoDescription*)photoAtIndex:(NSUInteger)index;
- (BOOL)isInFavourites:(CDPhotoDescription*)photo;

- (CDPhotoDescription*)addFavourite:(CDPhotoDescription*)photo;
- (void)removeFavourite:(CDPhotoDescription*)photo;
- (void)removeFavouriteAtIndex:(NSUInteger)index;
- (void)moveFavourite:(CDPhotoDescription*)photo toIndex:(NSUInteger)toIndex;
- (void)moveFavouriteFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

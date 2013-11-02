//
//  CDFavouriteAlbum.h
//  CodeDemo
//
//  Created by Bob Reid on 11/1/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDPhotoDescription.h"
#import "CDPhotoHandle.h"

static const NSString* CDFavouritePhotoAdded = @"CDFavouritePhotoAdded";
static const NSString* CDFavouritePhotoRemoved = @"CDFavouritePhotoRemoved";

@interface CDFavouriteAlbum : NSObject

@property (strong, nonatomic) NSArray* photos;

+ (CDFavouriteAlbum*)album;
- (void)addToFavourites:(CDPhotoDescription*)photo;
- (void)removeFromFavourites:(CDPhotoDescription*)photo;
- (void)clearPhotoCache;

@end

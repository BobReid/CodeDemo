//
//  CDPhotoHandle.h
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDFlickrManagedObject.h"

@class CDPhotoDescription;

@interface CDPhotoHandle : CDFlickrManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) CDPhotoDescription *photoDescription;

- (id)initThumbnailPhotoHandleForDescription:(CDPhotoDescription*)description;
- (id)initLargePhotoHandleForDescription:(CDPhotoDescription*)description;
- (id)initOriginalPhotoHandleForDescription:(CDPhotoDescription*)description;

- (BOOL)isThumbnail;
- (BOOL)isLargerThan:(CDPhotoHandle*)handle;
- (NSURLSessionDownloadTask*)downloadTaskForPhoto:(void(^)(NSError* error))completion;
- (BOOL)sizeCached;

@end

//
//  CDPhotoDescription.m
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDPhotoDescription.h"
#import "CDPhotoHandle.h"
#import "CDFlickrObjectContext.h"
#import "CDAppDelegate.h"
#import "NSManagedObjectContext+Async.h"
#import "NSManagedObjectContext+Copying.h"

@interface CDPhotoDescription()

+ (NSManagedObjectContext*)favouritesContext;
+ (CDFlickrObjectContext*)searchContext;

@end


@implementation CDPhotoDescription

@dynamic order;
@dynamic photoId;
@dynamic title;
@dynamic farmId;
@dynamic secret;
@dynamic serverId;
@dynamic originalSecret;
@dynamic originalFormat;
@dynamic thumbnailHandle;
@dynamic largestHandle;
@dynamic handles;

+ (CDFlickrObjectContext*)searchContext
{
    static CDFlickrObjectContext* searchContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CDAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        searchContext = [[CDFlickrObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [searchContext setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
    });
    return searchContext;
}

+ (void)searchForPhotosWithTerm:(NSString*)term page:(NSUInteger)page completion:(void(^)(NSArray* photos, NSError* error))completion
{
    static NSString* searchPredicate = @"method == 'flickr.photos.search' AND "
                                        "extras == 'original_format' AND "
                                        "content_type == '1' AND "
                                        "per_page == '30' AND "
                                        "page = %@ AND "
                                        "text = %@";
    
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDPhotoDescription"];
    [fetch setPredicate:[NSPredicate predicateWithFormat:searchPredicate, [NSString stringWithFormat:@"%u", (uint32_t)page], term, @"ad4e591c3ae8a5846676865c1727403a"]];
    
    [[[self class] searchContext] executeAsyncFetchRequest:fetch completion:completion];
}

- (void)setPropertiesFromJSON:(NSDictionary*)json
{
    [self setPhotoId:json[@"id"]];
    [self setSecret:json[@"secret"]];
    [self setFarmId:[json[@"farm"] stringValue]];
    [self setTitle:json[@"title"]];
    [self setServerId:json[@"server"]];
    
    if(json[@"originalformat"])
    {
        [self setOriginalFormat:json[@"originalformat"]];
        [self setOriginalSecret:json[@"originalsecret"]];
    }
    
    [self createPhotoHandles];
}

- (void)createPhotoHandles
{
    CDPhotoHandle* thumnail = [[CDPhotoHandle alloc] initThumbnailPhotoHandleForDescription:self];
    CDPhotoHandle* large    = [[CDPhotoHandle alloc] initLargePhotoHandleForDescription:self];

    [self setHandles:[NSSet setWithObjects:thumnail, large, nil]];
    [self setThumbnailHandle:thumnail];
    [self setLargestHandle:large];
    
    if([self originalFormat])
    {
        CDPhotoHandle* original = [[CDPhotoHandle alloc] initOriginalPhotoHandleForDescription:self];
        [self addHandlesObject:original];
        [self setLargestHandle:original];
    }
    
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    for(CDPhotoHandle* handle in self.handles)
    {
        if([handle isLargerThan:self.largestHandle])
        {
            [self setLargestHandle:handle];
        }
        
        if([handle isThumbnail])
        {
            [self setThumbnailHandle:handle];
        }
    }
}

- (NSString *)description
{
    NSMutableString* ret = [[NSMutableString alloc] init];
    [ret appendString:@"CDPhotoDescription{ "];
    [ret appendFormat:@"managedId: %@ -", self.objectID];
    [ret appendFormat:@"title: %@ - ", self.title];
    [ret appendFormat:@"farm: %@ - ", self.farmId];
    [ret appendFormat:@"secret: %@ - ", self.secret];
    [ret appendFormat:@"photoId: %@ - ", self.photoId];
    [ret appendFormat:@"handles: %@ - ", self.thumbnailHandle];
    [ret appendFormat:@"}"];
    
    return [NSString stringWithString:ret];
}


@end

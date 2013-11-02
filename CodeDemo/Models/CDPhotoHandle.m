//
//  CDPhotoHandle.m
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDPhotoHandle.h"
#import "CDPhotoDescription.h"
#import "CDFlickrObjectContext.h"
#import "CDAppDelegate.h"


// Forat : http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
// OriginalFormat : http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)

#define URL_FORMAT @"http://farm%@.staticflickr.com/%@/%@_%@_%@.%@"

static const NSString* PhotoHandleSizeThumbnail = @"s";
static const NSString* PhotoHandleSizeLarge     = @"l";
static const NSString* PhotoHandleSizeOrignal   = @"o";

static const NSString* PhotoHandleFormatJPG = @"jpg";

@implementation CDPhotoHandle

@dynamic filePath;
@dynamic height;
@dynamic url;
@dynamic width;
@dynamic photoDescription;

- (id)initThumbnailPhotoHandleForDescription:(CDPhotoDescription*)description
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"CDPhotoHandle" inManagedObjectContext:description.managedObjectContext] insertIntoManagedObjectContext:description.managedObjectContext];

    if(self)
    {
        [self setUrl:[NSString stringWithFormat:URL_FORMAT, description.farmId, description.serverId, description.photoId, description.secret, PhotoHandleSizeThumbnail, PhotoHandleFormatJPG]];
    }
    
    return self;
}

- (id)initLargePhotoHandleForDescription:(CDPhotoDescription*)description
{
    self = [super initWithEntity:[NSEntityDescription entityForName:@"CDPhotoHandle" inManagedObjectContext:description.managedObjectContext] insertIntoManagedObjectContext:description.managedObjectContext];
    
    if(self)
    {
        [self setUrl:[NSString stringWithFormat:URL_FORMAT, description.farmId, description.serverId, description.photoId, description.secret, PhotoHandleSizeLarge, PhotoHandleFormatJPG]];
    }
    
    return self;
}

- (id)initOriginalPhotoHandleForDescription:(CDPhotoDescription*)description
{
    NSParameterAssert(description.originalSecret);
    NSParameterAssert(description.originalFormat);
    
    self = [super initWithEntity:[NSEntityDescription entityForName:@"CDPhotoHandle" inManagedObjectContext:description.managedObjectContext] insertIntoManagedObjectContext:description.managedObjectContext];
    
    if(self)
    {
        [self setUrl:[NSString stringWithFormat:URL_FORMAT, description.farmId, description.serverId, description.photoId, description.originalSecret, PhotoHandleSizeOrignal, description.originalFormat]];
    }
    
    return self;
}

- (BOOL)isThumbnail
{
    return [self.url hasSuffix:[NSString stringWithFormat:@"%@.%@", PhotoHandleSizeThumbnail, PhotoHandleFormatJPG]];
}

- (BOOL)isLargerThan:(CDPhotoHandle*)other
{
    if(!other)
        return YES;
    
    if([other isThumbnail])
        return YES;
    
    if([self isThumbnail])
        return NO;
    
    NSArray* comps = [self.url componentsSeparatedByString:@"."];
    NSString* size = comps[[comps count] - 2];
    if([size hasSuffix:@"_o"])
        return YES;
    
    return NO;
}

- (void)prepareForDeletion
{
    if(![self filePath])
        return;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
    [fileManager removeItemAtURL:[NSURL URLWithString:[self filePath]] error:&error];
    
    if(error)
        NSLog(@"Error could not delete file %@", error);
}

- (BOOL)sizeCached
{
    return  [self height]   && [self.height floatValue] > 0 &&
            [self width]    && [self.width floatValue] > 0;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"CFPhotoHandle( %@ )", self.url];
}

- (NSURLSessionDownloadTask*)downloadTaskForPhoto:(void (^)(NSError *))completion
{

    NSURL* url = [NSURL URLWithString:self.url];
    
    //Do not allow caching of original images. We are storing these to disk manually. Save the URLCache for thumbnails
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
    
    
    NSURLSessionDownloadTask* task = [[CDFlickrObjectContext sessionManager] downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSArray* components = [self.url componentsSeparatedByString:@"/"];
        
        return [[((CDAppDelegate*)[[UIApplication sharedApplication] delegate]) tempDirectory] URLByAppendingPathComponent:components[[components count] - 1]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if(!error)
        {
            self.filePath = [filePath absoluteString];
        }
        else
        {
            NSLog(@"Download Image Failed: %@", error);
        }
        
        if(completion)
            completion(error);
    }];

    return task;
}

@end

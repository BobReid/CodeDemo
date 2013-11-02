//
//  CDFavouritePhotos.m
//  CodeDemo
//
//  Created by Bob Reid on 11/1/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDFavouritePhotos.h"
#import "CDFlickrObjectContext.h"
#import "CDAppDelegate.h"
#import "NSManagedObjectContext+Async.h"
#import "NSManagedObjectContext+Copying.h"

@interface CDFavouritePhotos ()
{
@private
    NSMutableArray* _photos;
}

- (CDFlickrObjectContext*)favouritesContext;
- (BOOL)saveContext;

@end


@implementation CDFavouritePhotos

- (NSManagedObjectContext*)favouritesContext
{
    return [((CDAppDelegate*)[[UIApplication sharedApplication] delegate]) managedObjectContext];
}

- (BOOL)saveContext
{
    NSError* error;
    [[self favouritesContext] save:&error];
    
    if(error)
        NSLog(@"%@", error);
    
    return error == nil;
}

+ (CDFavouritePhotos*)album
{
    static CDFavouritePhotos* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)loadPhotos
{
    if(_photos)
        return;
    
    NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDPhotoDescription"];
    [fetch setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    
    [[self favouritesContext] executeAsyncFetchRequest:fetch completion:^(NSArray *result, NSError *error) {
        
        if(error)
            return;
        
        _photos = [NSMutableArray arrayWithArray:result];
        [[NSNotificationCenter defaultCenter] postNotificationName:CDFavouritePhotosLoaded object:self];
    }];
}

- (void)unloadPhotos
{
    if(!_photos)
        return;
    
    [self saveContext];
    
    _photos = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:CDFavouritePhotosUnloaded object:self];
}

- (NSUInteger)count
{
    return [_photos count];
}

- (CDPhotoDescription*)photoAtIndex:(NSUInteger)index
{
    NSParameterAssert(index >= 0);
    NSParameterAssert(index < [self count]);
    
    return _photos[index];
}

- (BOOL)isInFavourites:(CDPhotoDescription*)photo
{
    NSParameterAssert(photo != nil);
    
    return [_photos containsObject:photo];
}

- (CDPhotoDescription*)addFavourite:(CDPhotoDescription*)photo
{
    NSParameterAssert(photo != nil);
    
    if([_photos containsObject:photo])
        return nil;
    
    CDPhotoDescription* saved = (CDPhotoDescription*)[[self favouritesContext] localInstanceOfObject:photo];
    [saved setOrder:[NSNumber numberWithUnsignedInteger:_photos.count]];
    
    
    NSURL* sourceUrl = [NSURL URLWithString:photo.largestHandle.filePath];
    NSString* fileName = [sourceUrl lastPathComponent];
    
    NSURL* destUrl = [[((CDAppDelegate*)[[UIApplication sharedApplication] delegate]) favouritesDirectory] URLByAppendingPathComponent:fileName];
    
    NSError* error;
    [[NSFileManager defaultManager] copyItemAtURL:sourceUrl toURL:destUrl error:&error];
    
    if(error)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        return nil;
    }
    
    [saved.largestHandle setFilePath:[destUrl absoluteString]];
    
    if(![self saveContext])
    {
        NSLog(@"Error: %@", [error localizedDescription]);
        [[NSFileManager defaultManager] removeItemAtURL:destUrl error:&error];
        NSLog(@"Error: %@", [error localizedDescription]);
        return nil;
    }

    [_photos addObject:saved];
    id userInfo = @{ CDFavouritePhotoToIndexKey : saved.order };
    [[NSNotificationCenter defaultCenter] postNotificationName:CDFavouritePhotoAdded object:photo userInfo:userInfo];
    
    return saved;
}

- (void)removeFavouriteAtIndex:(NSUInteger)index
{
    NSParameterAssert(index >= 0);
    NSParameterAssert(index < [self count]);
    
    [self removeFavourite:[self photoAtIndex:index]];
}
- (void)removeFavourite:(CDPhotoDescription*)photo
{
    NSParameterAssert(photo != nil);
    
    if(![_photos containsObject:photo])
        return;
    
    NSUInteger oldIndex = [_photos indexOfObject:photo];
    [[self favouritesContext] deleteObject:photo];
    
    if([self saveContext])
    {
        
        [_photos removeObjectAtIndex:oldIndex];
        for(NSUInteger i = oldIndex; i < [_photos count]; i++)
            [_photos[i] setOrder:[NSNumber numberWithUnsignedInteger:i]];
    }
    
    id userInfo = @{ CDFavouritePhotoFromIndexKey : [NSNumber numberWithUnsignedInteger:oldIndex] };
    [[NSNotificationCenter defaultCenter] postNotificationName:CDFavouritePhotoRemoved object:photo userInfo:userInfo];
}

- (void)moveFavouriteFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSParameterAssert(fromIndex >= 0);
    NSParameterAssert(fromIndex < [self count]);
    
    [self moveFavourite:[self photoAtIndex:fromIndex] toIndex:toIndex];
}

- (void)moveFavourite:(CDPhotoDescription*)photo toIndex:(NSUInteger)toIndex
{
    NSParameterAssert(photo != nil);
    NSParameterAssert(toIndex >= 0);
    NSParameterAssert(toIndex < [self count]);
    
    if(![_photos containsObject:photo])
        return;
    
    NSUInteger fromIndex = [photo.order unsignedIntegerValue];
    NSInteger direction = (fromIndex < toIndex) ? 1 : -1;
    
    for(NSUInteger i = fromIndex + direction; i <= toIndex; i += direction)
    {
        CDPhotoDescription* photo = [_photos objectAtIndex:i];
        NSNumber* newOrder = [NSNumber numberWithUnsignedInteger:[photo.order unsignedIntegerValue] - direction];
        [photo setOrder: newOrder];
    }
    
    [photo setOrder:[NSNumber numberWithUnsignedInteger:toIndex]];
    
    if([self saveContext])
    {
        [_photos removeObjectAtIndex:fromIndex];
        [_photos insertObject:photo atIndex:toIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:CDFavouritePhotoRepositioned
                                                            object:photo
                                                          userInfo:@{ CDFavouritePhotoFromIndexKey  : [NSNumber numberWithUnsignedInteger:fromIndex],
                                                                      CDFavouritePhotoToIndexKey    : [NSNumber numberWithUnsignedInteger:toIndex]}];
    }
}

@end

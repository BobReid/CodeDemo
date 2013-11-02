//
//  CDFavouriteAlbum.m
//  CodeDemo
//
//  Created by Bob Reid on 11/1/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDFavouriteAlbum.h"

@implementation CDFavouriteAlbum

+ (CDFavouriteAlbum*)album
{
    static CDFavouriteAlbum* album;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        album = [self init];
    });
    
    return album;
}

- (void)addToFavourites:(CDPhotoDescription*)photo
{
    if([self.photos containsObject:photo])
        return;
    
    [photo setOrder:[NSNumber numberWithInteger:self.photos.count]];
    self.photos = [self.photos arrayByAddingObject:photo];
}

- (void)removeFromFavourites:(CDPhotoDescription*)photo
{
    if(![self.photos containsObject:photo])
        return;
    
    NSMutableArray* temp = [self.photos mutableCopy];
    [temp removeObject:photo];
    [self setPhotos:[NSArray arrayWithArray:temp]];
}

- (void)movePhoto:photo fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSMutableArray* temp = [self.photos mutableCopy];
    
}

- (void)clearPhotoCache
{
    
}

@end

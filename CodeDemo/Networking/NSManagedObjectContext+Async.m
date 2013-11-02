//
//  NSManagedObjectContext+Async.m
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "NSManagedObjectContext+Async.h"
#import "NSManagedObjectContext+Copying.h"
#import "CDFlickrObjectContext.h"

@implementation NSManagedObjectContext (Async)

- (void)executeAsyncFetchRequest:(NSFetchRequest*)request completion:(void(^)(NSArray* result, NSError* error))completion
{
    NSManagedObjectContext* backgroundContext = [[[self class] alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    [backgroundContext performBlock:^{
        
        NSError* error;
        NSArray* result = [backgroundContext executeFetchRequest:request error:&error];
        
        if(error)
        {
            [self performBlock:^{
                if (completion)
                    completion(nil, error);
            }];
            return;
        }
        
        if([self isKindOfClass:[CDFlickrObjectContext class]])
        {
            [self copyResults:result fetchedFromContext:backgroundContext completion:completion];
        }
        else
        {
            [self refetch:request results:result fetchedFromContext:backgroundContext completion:completion];
        }
        
    }];
}


- (void)copyResults:(NSArray*)results
 fetchedFromContext:(NSManagedObjectContext*)backgroundContext
         completion:(void(^)(NSArray* result, NSError* error))completion
{
    [self performBlock:^{
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        //Retain context so we can copy the fetched objects to our return context
        NSManagedObjectContext* context = backgroundContext;
#pragma clang diagnostic pop
        
        NSMutableArray* ret = [NSMutableArray arrayWithCapacity:results.count];
        
        for(id obj in results)
        {
            [ret addObject:[self localInstanceOfObject:obj]];
        }
        
        if(completion)
            completion([NSArray arrayWithArray:ret], nil);
    }];
}

- (void)refetch:(NSFetchRequest*)fetch
        results:(NSArray*)results
fetchedFromContext:(NSManagedObjectContext*)context
     completion:(void(^)(NSArray* result, NSError* error))completion
{
    NSArray* resultIds = [results valueForKeyPath:@"@unionOfObjects.objectID"];
    NSFetchRequest* newFetch = [fetch copy];
    [newFetch setPredicate:[NSPredicate predicateWithFormat:@"self in (%@)", resultIds]];
    
    [self performBlock:^{
        
        NSError* error;
        NSArray* newResults = [self executeFetchRequest:newFetch error:&error];
        
        if(completion)
            completion(newResults, error);
    }];
}

@end

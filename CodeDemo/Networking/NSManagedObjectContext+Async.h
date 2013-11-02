//
//  NSManagedObjectContext+Async.h
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Async)

- (void)executeAsyncFetchRequest:(NSFetchRequest*)request completion:(void(^)(NSArray* result, NSError* error))completion;

@end

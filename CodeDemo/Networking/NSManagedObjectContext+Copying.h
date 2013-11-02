//
//  NSManagedObjectContext+Copying.h
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Copying)

- (NSManagedObject*)localInstanceOfObject:(NSManagedObject*)other;

@end

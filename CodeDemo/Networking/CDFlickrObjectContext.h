//
//  CDFlickrObjectContext.h
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AFNetworking.h"

@interface CDFlickrObjectContext : NSManagedObjectContext

+ (AFHTTPSessionManager*)sessionManager;
+ (void)setAPIKey:(NSString*)apiKey;
+ (NSString*)APIKey;

@end

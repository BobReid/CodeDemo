//
//  CDFlickrObjectContext.m
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDFlickrObjectContext.h"
#import "CDFlickrManagedObject.h"

static const NSString* FlickrApiURL = @"http://api.flickr.com/services/rest/";

@implementation CDFlickrObjectContext

static NSString* apiKey;

+ (void)setAPIKey:(NSString *)key
{
    apiKey = key;
}

+ (NSString*)APIKey
{
    return apiKey;
}

+ (AFHTTPSessionManager*)sessionManager
{
    static AFHTTPSessionManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:(NSString*)FlickrApiURL]];
    });
    
    return manager;
}

+ (AFHTTPRequestOperationManager*)operationManager
{
    static AFHTTPRequestOperationManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:(NSString*)FlickrApiURL]];
    });
    
    return manager;
}


- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error
{
    NSAssert([[self class] APIKey], @"Flickr API key must be set");
    
    NSMutableDictionary* params = [self jsonParamsFromRequest:request];
    
    
    AFHTTPRequestOperation* op = [[[self class] operationManager] GET:@"" parameters:params success:nil failure:nil];
    [op waitUntilFinished];
    
    NSError* __autoreleasing e = [op error];
    if(e)
    {
        error = &e;
        return nil;
    }
    
    NSDictionary* response = [op responseObject];
    
    NSMutableArray* objects = [NSMutableArray arrayWithCapacity:[[response valueForKeyPath:@"photos.photo.@count"] integerValue]];
    for(NSDictionary* json in [response valueForKeyPath:@"photos.photo"])
    {
        CDFlickrManagedObject* o = [NSEntityDescription insertNewObjectForEntityForName:request.entityName inManagedObjectContext:self];
        [o setPropertiesFromJSON:json];
        [objects addObject:o];
    }
    
    return objects;
}

- (NSMutableDictionary*)jsonParamsFromRequest:(NSFetchRequest*)fetchRequest
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [self addPredicate:fetchRequest.predicate toParams:params];

    params[@"format"] = @"json";
    params[@"nojsoncallback"] = @"1";
    params[@"api_key"] = [[self class] APIKey];
    
    return params;
}

- (void)addPredicate:(NSPredicate*)predicate toParams:(NSMutableDictionary*)params
{
    if([predicate isKindOfClass:[NSComparisonPredicate class]])
        [self addComparisonPredicate:(NSComparisonPredicate*)predicate toParams:params];
    else if([predicate isKindOfClass:[NSCompoundPredicate class]])
        [self addCompoundPredicate:(NSCompoundPredicate*)predicate toParams:params];
    else
        NSAssert(NO, @"Unsupported predicated type. Could not serialzie to Flickr params");

}

- (void)addCompoundPredicate:(NSCompoundPredicate*)predicate toParams:(NSMutableDictionary*)params
{
    NSAssert(predicate.compoundPredicateType == NSAndPredicateType, @"Only AND predicates are supported");
    
    for(NSPredicate* sub in predicate.subpredicates)
    {
        [self addPredicate:sub toParams:params];
    }
}

- (void)addComparisonPredicate:(NSComparisonPredicate*)predicate toParams:(NSMutableDictionary*)params
{
    NSAssert(predicate.predicateOperatorType == NSEqualToPredicateOperatorType, @"Only '==' predicate comparisons are supported");
    NSAssert(predicate.leftExpression.expressionType == NSKeyPathExpressionType, @"Left expression of comparison predicate must be a keypath");
    NSAssert(predicate.rightExpression.expressionType == NSConstantValueExpressionType, @"Right expression of comparison predicate must be a constant but was %@", predicate.rightExpression);
    
    params[predicate.leftExpression.keyPath] = [NSString stringWithFormat:@"%@", predicate.rightExpression.constantValue];
}

@end

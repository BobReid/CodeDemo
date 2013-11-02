//
//  NSManagedObjectContext+Copying.m
//  CodeDemo
//
//  Created by Bob Reid on 10/27/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "NSManagedObjectContext+Copying.h"

@implementation NSManagedObjectContext (Copying)

- (NSManagedObject*)localInstanceOfObject:(NSManagedObject*)other
{
    return [self localInstanceOfObject:other parentEntity:nil lookup:[NSMutableDictionary dictionary]];
}

- (NSManagedObject*)localInstanceOfObject:(NSManagedObject*)other parentEntity:(NSString*)parentEntity lookup:(NSMutableDictionary*)lookup
{
    if(!other || ![other isKindOfClass:[NSManagedObject class]])
        return nil;
    
    if([self objectRegisteredForID:[other objectID]])
        return other;
    
    if([lookup objectForKey:[other objectID]])
        return [lookup objectForKey:[other objectID]];
    
    NSString* entityName = [[other entity] name];
    NSManagedObject* ret = [[[other class] alloc] initWithEntity:[other entity] insertIntoManagedObjectContext:self];
    [lookup setObject:ret forKey:[other objectID]];
    
    for(NSString* key in [other.entity attributesByName])
    {
        id attribute = [other valueForKey:key];
        if(attribute)
           [ret setValue:attribute forKey:key];
    }
    
    NSDictionary* relationships = [other.entity relationshipsByName];
    for(NSString* key in relationships)
    {
        NSRelationshipDescription* rel = relationships[key];
        id value = [other valueForKey:key];
        
        if([rel isToMany])
        {
            NSMutableSet* set = [NSMutableSet set];
            for (id oldObj in value)
            {
                [set addObject:[self localInstanceOfObject:oldObj parentEntity:entityName lookup:lookup]];
            }
            [ret setValue:set forKey:key];
        }
        else
        {
            NSString* relEntityName = [[rel destinationEntity] name];
            
            id existing = [lookup objectForKey:[value objectID]];
            if(!existing && ![relEntityName isEqualToString:parentEntity])
                existing = [self localInstanceOfObject:value parentEntity:entityName lookup:lookup];
            
            [ret setValue:existing forKey:key];
        }
    }
    
    return ret;
}

@end

//
//  CDAppDelegate.h
//  CodeDemo
//
//  Created by Bob Reid on 10/24/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

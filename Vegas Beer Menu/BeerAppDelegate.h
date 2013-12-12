//
//  BeerAppDelegate.h
//  Vegas Beer Menu
//
//  Created by steven brian aten on 12/11/13.
//  Copyright (c) 2013 FIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeerAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

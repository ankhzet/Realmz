//
//  AZRInGameResourceManager.h
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRInGameResource.h"

@interface AZRInGameResourceManager : NSObject <NSCopying>

+ (instancetype) manager;

- (AZRInGameResource *) addResource:(NSString *)resourceName;
- (AZRInGameResource *) addResource:(NSString *)resourceName controlledBy:(AZRInGameResourceController *)controller;
- (AZRInGameResource *) resourceNamed:(NSString *)resourceName;
- (AZRInGameResource *) removeResource:(NSString *) resourceName;
- (NSArray *) registeredResources;

- (int) resourceNamed:(NSString *)resourceName addAmount:(int)amount;
- (int) resource:(AZRInGameResource *)resource addAmount:(int)amount;

@end

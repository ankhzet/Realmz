//
//  AZRInGameResourceManager.h
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRInGameResource.h"

@interface AZRInGameResourceManager : NSObject

+ (instancetype) manager;

- (AZRInGameResource *) addResource:(NSString *)resourceName;
- (AZRInGameResource *) addResource:(NSString *)resourceName controlledBy:(AZRInGameResourceController *)controller;
- (AZRInGameResource *) resourceNamed:(NSString *)resourceName;
- (AZRInGameResource *) removeResource:(NSString *) resourceName;
- (int) resource:(AZRInGameResource *)resource addAmount:(int)amount;

@end

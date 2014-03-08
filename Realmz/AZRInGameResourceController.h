//
//  AZRInGameResourceController.h
//  Realmz
//
//  Plain resource controller. Only manages integer resource value, no checks, no calcs etc.
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRInGameResource;
@interface AZRInGameResourceController : NSObject

+ (instancetype) controller;

- (int) resourceAmount:(AZRInGameResource *)resource;
- (int) resource:(AZRInGameResource *)resource setAmount:(int)amount;

@end

//
//  AZRInGameResource.h
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRInGameResourceController;
@interface AZRInGameResource : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) int amount;
@property (nonatomic) AZRInGameResourceController *controller;

+ (instancetype) resourceWithName:(NSString *)resourceName;

- (BOOL) enoughtResource:(int)amountRequired;
- (int) addAmount:(int)amountToAdd;

@end

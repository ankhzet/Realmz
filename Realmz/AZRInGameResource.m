//
//  AZRInGameResource.m
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRInGameResource.h"
#import "AZRInGameResource+Protected.h"
#import "AZRInGameResourceController.h"

@implementation AZRInGameResource
@synthesize amount = plainAmount;

#pragma mark - Instantiation

+ (instancetype) resourceWithName:(NSString *)resourceName {
}

#pragma mark - Implementation

- (BOOL) enoughtResource:(int)amountRequired {
}

- (int) addAmount:(int)amountToAdd {
}

- (int) amount {
}

@end

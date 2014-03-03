//
//  AZRInGameResourceController.m
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRInGameResourceController.h"
#import "AZRInGameResource+Protected.h"

@implementation AZRInGameResourceController

#pragma mark - Instantiation

+ (instancetype) controller {
	return [[self alloc] init];
}

+ (instancetype) new {
	return [self controller];
}

#pragma mark - Controller

- (int) resourceAmount:(AZRInGameResource *)resource {
	return resource->plainAmount;
}

- (int) resource:(AZRInGameResource *)resource setAmount:(int)amount {
	return resource->plainAmount = MAX(0, amount);
}

@end

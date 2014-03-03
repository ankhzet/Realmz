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
	return [[self alloc] initWithName:resourceName];
}

- (id)initWithName:(NSString *)resourceName {
	if (!(self = [super init]))
		return self;

	_name = resourceName;
	return self;
}

#pragma mark - Implementation

- (BOOL) enoughtResource:(int)amountRequired {
	return [self amount] >= amountRequired;
}

- (int) addAmount:(int)amountToAdd {
	return _controller ? [_controller resource:self setAmount:([self amount] + amountToAdd)] : (plainAmount += amountToAdd);
}

- (int) amount {
	return _controller ? [_controller resourceAmount:self] : plainAmount;
}

@end

//
//  AZRInGameResourceManager.m
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRInGameResourceManager.h"

@interface AZRInGameResourceManager ()
@property (nonatomic) NSMutableDictionary *resources;
@end
@implementation AZRInGameResourceManager

#pragma mark - Instantiation

- (id)init {
	if (!(self = [super init]))
		return self;

	_resources = [NSMutableDictionary dictionary];
	return self;
}

+ (instancetype) manager {
	return [[self alloc] init];
}

+ (instancetype) new {
	return [self manager];
}

- (id) copyWithZone:(NSZone *)zone  {
	AZRInGameResourceManager *instance = [AZRInGameResourceManager manager];
	for (AZRInGameResource *resource in [_resources allValues]) {
    [instance addResource:resource.name controlledBy:resource.controller];
	}
	return instance;
}

#pragma mark - Resource managing

- (AZRInGameResource *) addResource:(NSString *)resourceName {
	AZRInGameResource *resource = [AZRInGameResource resourceWithName:resourceName];
	_resources[resourceName] = resource;
	return resource;
}

- (AZRInGameResource *) addResource:(NSString *)resourceName controlledBy:(AZRInGameResourceController *)controller {
	AZRInGameResource *resource = [self addResource:resourceName];
	resource.controller = controller;
	return resource;
}

- (AZRInGameResource *) resourceNamed:(NSString *)resourceName {
	return _resources[resourceName];
}

- (AZRInGameResource *) removeResource:(NSString *) resourceName {
	AZRInGameResource *resource = [self resourceNamed:resourceName];
	if (resource) {
		[_resources removeObjectForKey:resourceName];
	}

	return resource;
}

- (int) resource:(AZRInGameResource *)resource addAmount:(int)amount {
	return [resource addAmount:amount];
}

@end

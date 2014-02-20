//
//  AZRActorObjectsMemory.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActorObjectsMemory.h"

#import "AZRObject.h"

@interface AZRActorObjectsMemory ()
@property (nonatomic) NSMutableDictionary *objectsMemory;
@property (nonatomic) NSMutableDictionary *propertiesMemory;
@end

@implementation AZRActorObjectsMemory

- (NSDictionary *) allMemory {
	return self.objectsMemory;
}

- (void) objectSeen:(AZRObject *)object {
	if (!self.objectsMemory)
		self.objectsMemory = [NSMutableDictionary dictionary];
	
	NSMutableSet *group = self.objectsMemory[object.classDescription.name];
	if (!group) {
		group = [NSMutableSet set];
		self.objectsMemory[object.classDescription.name] = group;
//		self.propertiesMemory[object.description.name] = [object.description.publicProperties mutableCopy];
	}
	
	[group addObject:object];
}

- (void) objectInspected:(AZRObject *)object {
	[self objectSeen:object];
	[self discoverPropertiesForObject:object];
}

- (void) discoverPropertiesForObject:(AZRObject *)object {
	if (!self.propertiesMemory)
		self.propertiesMemory = [NSMutableDictionary dictionary];
	
	NSMutableSet *group = self.propertiesMemory[[object AZRClass]];
	if (!group) {
		group = [NSMutableSet set];
		self.propertiesMemory[[object AZRClass]] = group;
	}
	
	for (NSString *property in [object.properties allKeys]) {
		[group addObject:property];
	}
}

- (void) property:(NSString *)property discoveredForObject:(AZRObject *)object {
	if (!self.propertiesMemory)
		self.propertiesMemory = [NSMutableDictionary dictionary];
	
	NSMutableSet *group = self.propertiesMemory[object.classDescription.name];
	if (!group) {
		group = [NSMutableSet set];
		self.propertiesMemory[object.classDescription.name] = group;
	}
	
	[group addObject:property];
}

- (BOOL) knownProperty:(NSString *)property forObject:(AZRObject *)object {
	NSSet *group = self.propertiesMemory[object.classDescription.name];
	return group && [group member:property];
}

@end

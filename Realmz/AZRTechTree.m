//
//  AZRTechTree.m
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechTree.h"
#import "AZRTechnology.h"
#import "AZRInGameResourceManager.h"
#import "AZRInGameResource.h"

@implementation AZRTechTree
@synthesize technologies = _technologies;

#pragma mark - Instantiation

+ (instancetype) techTree {
	return [[self alloc] init];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	_technologies = [NSMutableDictionary dictionary];
	return self;
}

+ (instancetype) new {
	return [self techTree];
}

#pragma mark - Process

/*!
 @summary Process tech-tree. All techs will be re-calced for their availability, in-process techs will be processed.
 */
- (void) process:(NSTimeInterval)lastTick {
	for (AZRTechnology *tech in [_technologies allValues]) {
		[tech process:lastTick];
	}
}

#pragma mark - Tech management

- (void) addTech:(AZRTechnology *)technology {
	_technologies[technology.name] = technology;
	technology.techTree = self;
}

- (AZRTechnology *) techNamed:(NSString *)techName {
	return _technologies[techName];
}

- (AZRTechnology *) removeTech:(NSString *)techName {
	AZRTechnology *tech = [self techNamed:techName];
	if (tech)
		[_technologies removeObjectForKey:techName];
	return tech;
}

- (NSDictionary *) fetchTechStates {
	NSNumber *normalState = @(AZRTechnologyStateNormal);
	NSArray *states =
	@[
		normalState,
		@(AZRTechnologyStateNotImplementable),
		@(AZRTechnologyStateImplemented),
		@(AZRTechnologyStateUnavailable),
		@(AZRTechnologyStateInProcess),
		];
	NSMutableDictionary *fetch = [NSMutableDictionary dictionary];
	for (NSNumber *state in states) {
    fetch[state] = [NSMutableArray array];
	}
	for (AZRTechnology *tech in [_technologies allValues]) {
    int used = 0;
		for (NSNumber *state in states) {
			if (TEST_BIT(tech.state, [state integerValue])) {
				used++;
				[fetch[state] addObject:tech];
			}
		}
		if (!used) {
			[fetch[normalState] addObject:tech];
		}
	}

	return fetch;
}


- (NSArray *) fetchTechDependencies:(AZRTechnology *)tech {
	NSMutableArray *fetch = [NSMutableArray array];
	for (AZRTechnology *testTech in [_technologies allValues]) {
    if ([testTech isDependentOf:tech]) {
			[fetch addObject:testTech];
		}
	}
	return fetch;
}

#pragma mark - Resources

- (BOOL) isResourceAvailable:(AZRTechResource *)techResource {
	switch (techResource.type) {
		case AZRTechResourceTypeResource:
		{
			AZRInGameResource *resource = [_resourceManager resourceNamed:techResource.resource];
			return resource && [resource enoughtResource:techResource.amount];
		}
		case AZRTechResourceTypeTech:
		{
			AZRTechnology *tech = [self techNamed:techResource.resource];
			return tech && [tech isImplemented];
		}
		case AZRTechResourceTypeUnit:
		{
			//TODO: unit resource availablility check
			return NO;
		}
	}
	// unknown resource? O_o
	return NO;
}

- (BOOL) drainResource:(AZRTechResource *)techResource targeted:(id)target {
	switch (techResource.handler) {
		case AZRResourceHandlerTargeted:
			if (!target) {
				return NO;
			}
			break;
		default:
			break;
	}

	switch (techResource.type) {
		case AZRTechResourceTypeResource:
		{
			AZRInGameResource *resource = [_resourceManager resourceNamed:techResource.resource];
			if (resource && [resource enoughtResource:techResource.amount]) {
				[resource addAmount:-techResource.amount];
			} else
				return NO;
		}
		case AZRTechResourceTypeTech:
		{
			AZRTechnology *tech = [self techNamed:techResource.resource];
			if (tech) {
				[tech forceImplemented:NO];
			} else
				return NO;
		}
		default:
			return NO;
	}

	return YES;
}

- (BOOL) gainResource:(AZRTechResource *)techResource targeted:(id)target {
	switch (techResource.handler) {
		case AZRResourceHandlerTargeted:
			if (!target) {
				return NO;
			}
			break;
		default:
			break;
	}

	switch (techResource.type) {
		case AZRTechResourceTypeResource:
		{
			AZRInGameResource *resource = [_resourceManager resourceNamed:techResource.resource];
			if (resource && [resource enoughtResource:techResource.amount]) {
				[resource addAmount:techResource.amount];
			} else
				return NO;
		}
		case AZRTechResourceTypeTech:
		{
			AZRTechnology *tech = [self techNamed:techResource.resource];
			if (tech) {
				[tech forceImplemented:YES];
			} else
				return NO;
		}
		default:
			return NO;
	}

	return YES;
}

@end

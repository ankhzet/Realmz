//
//  AZRTechTree.m
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechTree.h"
#import "AZRTechnology.h"

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
    [tech calcAvailability];
		if ([tech isInProcess])
			[tech process:lastTick];
	}
}

#pragma mark - Tech management

- (void) addTech:(AZRTechnology *)technology {
	_technologies[technology.name] = technology;
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
	NSMutableArray *normal = [NSMutableArray array];
	NSMutableArray *unavailable = [NSMutableArray array];
	NSMutableArray *inprocess = [NSMutableArray array];
	NSDictionary *fetch =
	@{
		@(AZRTechnologyStateNormal): normal,
		@(AZRTechnologyStateUnavailable): unavailable,
		@(AZRTechnologyStateInProcess): inprocess,
		};

	for (AZRTechnology *tech in [_technologies allValues]) {
		BOOL isUnavailable = [tech isUnavailable];
		BOOL isInProcess = [tech isInProcess];
		if (isUnavailable) [unavailable addObject:tech];
		if (isInProcess) [inprocess addObject:tech];
		if (!(isInProcess || isUnavailable)) [normal addObject:tech];
	}
	return fetch;
}


@end

//
//  AZRTechnology.m
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechnology.h"
#import "AZRTechnology+Protected.h"
#import "AZRTechTree.h"
#import "AZRTechIteration.h"

@implementation AZRTechnology

#pragma mark - Instantiation

+ (instancetype) technology:(NSString *)techName inTechTree:(AZRTechTree *)techsTree {
	AZRTechnology *tech = [techsTree techNamed:techName];
	if (!tech) {
		AZRTechLoader *loader = [AZRTechLoader new];
		tech = [loader loadFromFile:techName];
	}
	if (!tech) {
		[AZRLogger log:NSStringFromClass(self) withMessage:@"Failed to load tech, creating dummy istance instead"];
		tech = [[self alloc] initWithName:techName];
	}

	[techsTree addTech:tech];
	return tech;
}

- (id)initWithName:(NSString *)techName {
	if (!(self = [super init]))
		return self;

	_state = 0;
	_iterations = [NSMutableArray array];
	self.name = techName;
	return self;
}

#pragma mark - Tech state

/*!
 @brief Checks required techs implementation state.
 @return Returns YES if all required techs implemented, NO otherwise.
 */
- (BOOL) isImplementable {
	return !TEST_BIT(_state, AZRTechnologyStateNotImplementable);
}

/*!
 @brief Returns YES if implemented.
 */
- (BOOL) isImplemented {
	return TEST_BIT(_state, AZRTechnologyStateImplemented);
}

/*!
 @brief Returns YES if not implementable or not enought resources.
 */
- (BOOL) isUnavailable {
	return TEST_BIT(_state, AZRTechnologyStateUnavailable);
}

/*!
 @brief Returns YES if in process of implementation.
 */
- (BOOL) isInProcess {
	return TEST_BIT(_state, AZRTechnologyStateInProcess);
}

- (void) forceImplementable:(BOOL)implementable {
	self.state = SET_BIT(self.state, AZRTechnologyStateNotImplementable, !implementable);
}

- (void) forceUnavailable:(BOOL)unavailable {
	self.state = SET_BIT(self.state, AZRTechnologyStateUnavailable, unavailable);
}

- (void) forceInProcess:(BOOL)inProcess {
	self.state = SET_BIT(self.state, AZRTechnologyStateInProcess, inProcess);
}

- (void) forceImplemented:(BOOL)implemented {
	self.state = SET_BIT(self.state, AZRTechnologyStateImplemented, implemented);
	if (implemented) {
		[self forceImplementable:NO];
	} else
		[self dependency:nil implemented:YES];

	NSArray *dependent = [self fetchDependent];
	for (AZRTechnology *tech in dependent) {
    [tech dependency:self implemented:implemented];
	}
}


#pragma mark - Dependencies

/*!
 @brief Add tech, required for implementation.
 @return Returns corresponding tech, if finded in tech tree.
 */
- (AZRTechnology *) addRequired:(NSString *)techName {
	if (!_requiredTechs) {
		_requiredTechs = [NSMutableArray array];
	}

	AZRTechnology *tech = [_techTree techNamed:techName];
	if (tech) {
		[self dependency:tech implemented:[tech isImplemented]];
		if (![_requiredTechs containsObject:tech])
			[(NSMutableArray *) _requiredTechs addObject:[NSValue valueWithNonretainedObject:tech]];
	}

	return tech;
}

/*!
 @brief Returns YES if receiver tech requires provided tech for implementation.
 */
- (BOOL) isDependentOf:(AZRTechnology *)tech {
	for (NSValue *holder in _requiredTechs) {
    if ([holder nonretainedObjectValue] == tech) {
			return YES;
		}
	}
	return NO;
}

/*!
 @brief Fetch all techs, dependant from message-receiver tech.
 */
- (NSArray *) fetchDependent {
	return [_techTree fetchTechDependencies:self];
}

/*!
 @brief Notify dependent tech about sender's implementation state change.
 */
- (void) dependency:(AZRTechnology *)tech implemented:(BOOL)implemented {
	BOOL isImplementable = implemented;
	if (isImplementable) {
		AZRTechnology *dependency;
		for (NSValue *holder in _requiredTechs) {
			if ((dependency = [holder nonretainedObjectValue]) != tech)
				isImplementable &= [dependency isImplemented];

			if (!isImplementable)
				break;
		}
  }
	_state = SET_BIT(_state, AZRTechnologyStateNotImplementable, !isImplementable);
}

#pragma mark - Drains & gains

- (AZRTechResource *) addDrain:(AZRTechResourceType)resourceType {
	AZRTechResource *resource = [AZRTechResource resourceWithType:resourceType];
	NSMutableArray *array = _drains[@(resourceType)];
	if (!array) {
		if (!_drains) {
			_drains = [NSMutableDictionary dictionary];
		}
		array = _drains[@(resourceType)] = [NSMutableArray array];
	}
	[array addObject:resource];
	return resource;
}

- (AZRTechResource *) addGain:(AZRTechResourceType)resourceType {
	AZRTechResource *resource = [AZRTechResource resourceWithType:resourceType];
	NSMutableArray *array = _gains[@(resourceType)];
	if (!array) {
		if (!_gains) {
			_gains = [NSMutableDictionary dictionary];
		}
		array = _gains[@(resourceType)] = [NSMutableArray array];
	}
	[array addObject:resource];
	return resource;
}

- (NSArray *) getGained:(AZRTechResourceType)resourceType {
	return _gains[@(resourceType)];
}

- (NSArray *) getDrained:(AZRTechResourceType)resourceType {
	return _drains[@(resourceType)];
}

#pragma mark - Implementing

- (BOOL) implement:(BOOL)implement withTarget:(id)target {
	if (implement) {
		BOOL available = [self calcAvailability];
		if (!available)
			return NO;

		if (![self preImplement:target])
			return NO;

		[self pushIteration:target];
		[self forceInProcess:YES];
	} else
		[self unImplement];

	return YES;
}

- (void) unImplement {
	if ([_iterations count]) {
		AZRTechIteration *iteration = [_iterations lastObject];
		[(NSMutableArray *)_iterations removeLastObject];
		[self revertPreImplement:iteration->target];
	}

	if (![_iterations count]) {
		[self forceInProcess:NO];
	}
}

#pragma mark - Iterational processing

- (void) process:(NSTimeInterval)lastTick {
	[self calcAvailability];
	if ([self isInProcess])
		[self processProgress:lastTick];
}


@end

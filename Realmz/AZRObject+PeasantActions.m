//
//  AZRObject+PeasantActions.m
//  Realmz
//
//  Created by Ankh on 18.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject+PeasantActions.h"
#import "AZRObject.h"
#import "AZRActor.h"
#import "AZRObjectProperty.h"
#import "AZRObject+VisibleObject.h"


#pragma mark - Peasant properties/actions constants

AZRObjectCommonProperty const AZRActorCommonPropertyBaggage = @"baggage";
AZRObjectCommonProperty const AZRActorCommonPropertyCanCarry = @"can-carry";


AZRActorCommonAction const AZRActorCommonActionMineResource = @"mine-resource";
AZRActorCommonAction const AZRActorCommonActionCarryResource = @"carry-resource";

#pragma mark - Peasant actions implementations

@implementation AZRObject (PeasantActions)

- (BOOL) actionMineResourceWithInitiator:(AZRActor *)initiator {
	// resource, carried by peasant
	AZRObjectProperty *resources = [initiator.properties objectForKey:AZRActorCommonPropertyBaggage];

	BOOL sameResource = YES;
	if (resources) {
		// is he carrying same resource, as he trying to chop?
		NSString *carriedResource = resources.vectorValue[0];
		sameResource = [[self AZRClass] isEqualToString:carriedResource];
		if (!sameResource) {
			// no, transport carried resource to storage first
			if (![initiator scheduleGoal:AZRActorCommonActionCarryResource imperative:NO]) {
				[AZRLogger log:NSStringFromClass([self class])
					 withMessage:@"%@ can't %%{%@} [%@], before he transports [%@] to storage, but he don't know how to %%{%@}", [initiator AZRClass], AZRActorCommonActionMineResource, [self AZRClass], carriedResource, AZRActorCommonActionCarryResource];
				return NO;
			}
			return NO;
		}
	}

	// chopping...

	float carried = resources ? [(NSNumber *)(resources.vectorValue[1]) floatValue] : 0.f;
	float maxToCarry = [initiator floatProperty:AZRActorCommonPropertyCanCarry];
	float maxToGather = [self health];
	// chop 5-15% or max carried
	float amount = maxToCarry * (0.05 + 0.1 * (arc4random() % 11) / 20.f);

	amount = (int)MIN(MIN(amount, maxToGather), maxToCarry - carried);
	[self floatPropertyIncrease:AZRObjectCommonPropertyHealth withValue:-amount];

	amount += carried;

	if (!resources)
		resources = [initiator addProperty:AZRActorCommonPropertyBaggage];

	if (!resources.vectorValue)
		resources.vectorValue = [NSMutableArray arrayWithObjects:[self AZRClass], @(amount), nil];
	else {
		if (!sameResource) ((NSMutableArray *)resources.vectorValue)[0] = [self AZRClass];
		((NSMutableArray *)resources.vectorValue)[1] = @(amount);
	}

	[AZRLogger log:nil withMessage:@"%@ gathered %.2f of %@", [initiator AZRClass], amount - carried, [self AZRClass]];
	[AZRLogger clearLog:nil];
	return YES;
}

- (BOOL) actionFreePeasantWithInitiator:(AZRActor *)initiator {
	[initiator scheduleGoal:nil imperative:YES];
	return YES;
}

@end

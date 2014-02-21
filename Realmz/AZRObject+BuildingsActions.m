//
//  AZRObject+BuildingsActions.m
//  Realmz
//
//  Created by Ankh on 19.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject+BuildingsActions.h"
#import "AZRObject+PeasantActions.h"
#import "AZRObject.h"
#import "AZRActor.h"
#import "AZRObjectProperty.h"
#import "AZRObject+VisibleObject.h"
#import "AZRActionIntent.h"


#pragma mark - Buildings properties/actions constants

AZRObjectCommonProperty const AZRBuildingCommonPropertyVolume = @"volume";
AZRObjectCommonProperty const AZRBuildingCommonPropertyFilled = @"filled";

#pragma mark - Buildings actions implementations

@implementation AZRObject (BuildingsActions)

- (BOOL) actionUnloadResourcesWithInitiator:(AZRActor *)initiator {
	// resource, carried by peasant
	AZRObjectProperty *resources = [initiator.properties objectForKey:AZRActorCommonPropertyBaggage];

	if (!resources) {
		return NO;
	}

	NSString *carriedResource = resources.vectorValue[0];
	float carried = [(NSNumber *)(resources.vectorValue[1]) floatValue];

	float volume = [self floatProperty:AZRBuildingCommonPropertyVolume];
	float filled = [self floatProperty:AZRBuildingCommonPropertyFilled];

	float canUnload = (int)MIN(carried, (int)volume * (1.f - filled));

	((NSMutableArray *)resources.vectorValue)[1] = @(MAX(0, carried - canUnload));
	float now = [self floatPropertyIncrease:AZRBuildingCommonPropertyFilled withValue:canUnload / volume];

	[AZRLogger log:nil withMessage:@"%@ unloaded %.2f of %@ to storage (%.2f now)", [initiator AZRClass], canUnload, carriedResource, now * volume];
	[AZRLogger clearLog:nil];

	return YES;
}

@end

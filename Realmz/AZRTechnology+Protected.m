//
//  AZRTechnology+Protected.m
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechnology+Protected.h"
#import "AZRTechTree.h"
#import "AZRTechIteration.h"

@implementation AZRTechnology (Protected)

#pragma mark - Availability

- (BOOL) calcAvailability {
	BOOL available = YES;

	BOOL noMoreIterations = (self.multiple > 0) && ([self.iterations count] >= self.multiple);
	if (noMoreIterations) {
		available = NO;
	} else
		for (NSArray *group in [self.drains allValues]) {
			for (AZRTechResource *resource in group) {
				if (![self.techTree isResourceAvailable:resource]) {
					available = NO;
					break;
				}
			}
		}

	[self forceUnavailable:!available];

	return available;
}

#pragma mark - Implementation

- (BOOL) preImplement:(id)target {
	for (NSArray *typeGroup in [self.drains allValues]) {
    for (AZRTechResource *resource in typeGroup) {
			if (![self.techTree drainResource:resource targeted:target])
				return NO;
		}
	}
	return YES;
}

- (void) postImplement:(id)target {
	for (NSArray *typeGroup in [self.gains allValues]) {
    for (AZRTechResource *resource in typeGroup) {
			[self.techTree gainResource:resource targeted:target];
		}
	}
}

- (void) revertPreImplement:(id)target {
	for (NSArray *typeGroup in [self.drains allValues]) {
    for (AZRTechResource *resource in typeGroup) {
			[self.techTree gainResource:resource targeted:target];
		}
	}
}

- (void) pushIteration:(id)target {
	AZRTechIteration *iteration = [AZRTechIteration iterationWithDuration:self.iterationTime];
	iteration->target = target;
	[(NSMutableArray *)self.iterations addObject:iteration];
}

#pragma mark - Progress

- (void) processProgress:(NSTimeInterval)lastTick {
	AZRTechIteration *iteration = [self.iterations firstObject];
	if ([iteration isFinished]) {
		id target = iteration->target;
		[(NSMutableArray *)self.iterations removeObjectAtIndex:0];
		if (self.final) {
			[self forceImplemented:YES];
		}
		if ([self.iterations count]) {
			iteration = [self.iterations firstObject];
			[iteration start];
		}
		[self postImplement:target];
	}
}

@end

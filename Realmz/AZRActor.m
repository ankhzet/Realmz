//
//  AZRActor.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActor.h"

#import "AZRActorClassDescription.h"
#import "AZRActorBrain.h"
#import "AZRActorNeed.h"
#import "AZRRealm.h"
#import "AZRObject+VisibleObject.h"

AZRActorNeedIdentifier const AZRActorNeedExitement = @"exitement";
AZRActorNeedIdentifier const AZRActorNeedThirst = @"thirst";
AZRActorNeedIdentifier const AZRActorNeedHunger = @"hungry";


@interface AZRActor () {
	NSMutableDictionary *needsImportance;
	NSTimeInterval lastReCalc;
	BOOL moved;
	NSMutableArray *goalStack;
}
@end

@implementation AZRActor
	
- (id) initFromDescription:(AZRObjectClassDescription *)description {
	if (!(self = [super initFromDescription:description]))
	return nil;
	
	self.needs = [NSMutableDictionary dictionary];
	self.knownObjects = [AZRActorObjectsMemory new];
	brain = [[AZRActorBrain alloc] initForActor:self];
	goalStack = [NSMutableArray array];
	moved = NO;
	
	return self;
}

- (void) initBrains:(AZRLogicGoal *)logic {
	[self->brain setGoal:logic];
}

- (void) processNeeds {
	AZRActorNeed *exitement = [self.needs objectForKey:AZRActorNeedExitement];
	exitement.currentValue *= 1.0f - (arc4random() % 1000000) / 5000000.f;
	
	NSMutableArray *list1 = [NSMutableArray array];
	NSMutableArray *list2 = [NSMutableArray array];
	for (AZRActorNeed *need in [self.needs allValues]) {
    if ([need isAtRedZone]) {
			[list1 addObject:need];
		} else
			if ([need isAtYelowZone]) {
				[list2 addObject:need];
			}
	}
	
	needsImportance = needsImportance ? needsImportance : (needsImportance = [@{@(YES):@{}, @(NO):@{}} mutableCopy]);
	[needsImportance setObject:list1 forKey:@(YES)];
	[needsImportance setObject:list2 forKey:@(NO)];
}

- (NSDictionary *) pickImportantNeeds {
	return needsImportance ? needsImportance : (needsImportance = [@{@(YES):@{}, @(NO):@{}} mutableCopy]);
}

- (void) updateViewSight {
	CGPoint pos = [self coordinates];
	float viewSight = [((AZRActorClassDescription *)self.classDescription).viewSight floatValue];
	NSArray *inRange = [self->realm inRangeOf:pos withDistanceOf:viewSight];
	for (AZRObject *object in inRange) {
		if (object != self)
			[self.knownObjects objectSeen:object];
	}
	
	moved = NO;
}

- (void) updateState:(NSTimeInterval)timestamp {
	[self processNeeds];
	if (moved) [self updateViewSight];
	lastReCalc = timestamp;
}

- (BOOL) scheduleGoal:(NSString *)goalName imperative:(BOOL)imperative {
	return [self scheduleGoal:goalName targetedAt:nil imperative:imperative];
}

- (BOOL) scheduleGoal:(NSString *)goalName targetedAt:(NSValue *)coordinates imperative:(BOOL)imperative  {
	if (imperative)
		[goalStack removeAllObjects];

	if ([goalStack count]) {
		NSMutableArray *pendingGoal = [goalStack objectAtIndex:0];
		if ([pendingGoal[0] isEqualToString:goalName]) {
			return NO;
		}
	}

	BOOL scheduled = [brain scheduleGoal:goalName];
	if (!scheduled)
		return NO;

	if (!goalName)
		return YES;

	[self setTargetedTo:coordinates];

	[goalStack insertObject:[@[goalName, coordinates ? coordinates : [NSNull null]] mutableCopy] atIndex:0];

	return YES;
}

- (BOOL) think:(NSTimeInterval)timestamp {
	if (timestamp - lastReCalc > 1.0f)
		[self updateState:timestamp];

	if ([brain isExecuted] && [goalStack count]) {
		[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Achieved prime goal %%{%@}", goalStack[0][0]];
		[goalStack removeObjectAtIndex:0];
		if ([goalStack count]) {
			NSArray *pendingGoal = [goalStack objectAtIndex:0];
			[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Achieving pended goal %%{%@}", pendingGoal[0]];
			if ([brain scheduleGoal:pendingGoal[0]]) {
				[self setTargetedTo:pendingGoal[1] == [NSNull null] ? nil : pendingGoal[1]];
			} else {
				[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Failed to schedule %%{%@} for %@", pendingGoal[0], [self AZRClass]];
				return NO;
			}
		}
	}
	return [self->brain think];
}

- (void) moveToXY:(CGPoint)targetXY {
	[super moveToXY:targetXY];
	moved = YES;
}
	
@end

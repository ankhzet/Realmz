//
//  AZRGoalSchedule.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActorBrain.h"
#import "AZRActor.h"

@interface AZRActorBrain () {
	__weak AZRLogicGoal *rootGoal;
	AZRScheduledGoal *goalSchedule;
	__weak AZRActor *actor;
}
@end
@implementation AZRActorBrain

- (id) initForActor:(AZRActor *)theActor {
	if (!(self = [super init]))
		return nil;
	
	self->goalSchedule = [AZRScheduledGoal new];
	self->actor = theActor;
	return self;
}

- (void) setGoal:(AZRLogicGoal *)goal {
	if (goal.ownage != AZRLogicGoalOwnageTypeRootNode) {
		for (AZRLogicGoal *subGoal in [goal subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode]) {
			if (subGoal.ownage == AZRLogicGoalOwnageTypeRootNode) {
				self->rootGoal = subGoal;
				break;
			}
		}
	}
	
	if (!self->rootGoal)
		self->rootGoal = goal;
	
	[self->goalSchedule setRequestor:nil];
	[self->goalSchedule setGoal:self->rootGoal];
	
	[super setGoal:goal];
}

- (BOOL) think {
	[self->goalSchedule setExecuted:NO];
	return [self isExecuted] ? [self->goalSchedule executeforActor:actor] : [self executeforActor:actor];
}

- (AZRLogicGoal *) findGoal:(NSString *)goalName {
	return [self.goal findGoal:goalName];
}

- (BOOL) scheduleGoal:(NSString *)goalName {
	if (!goalName) {
		[self setExecuted:YES];
		return YES;
	}

	AZRLogicGoal *goal = [self findGoal:goalName];
	if (goal) {
		[self setExecuted:NO];
		[self scheduleSubGoal:goal];
	} else
		[AZRLogger log:NSStringFromClass([self class]) withMessage:@"%@ doesn't know how to %%{%@}", [self->actor AZRClass], goalName];

	return !!goal;
}

@end

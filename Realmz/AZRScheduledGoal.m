//
//  AZRScheduledGoal.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRScheduledGoal.h"

#import "AZRActor.h"
#import "AZRGoalTargetSelector.h"

@interface AZRScheduledGoal ()
{
	BOOL achievedGoal;
	BOOL executedGoal;
}
@end

@implementation AZRScheduledGoal

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self->executedGoal = NO;
	self->achievedGoal = NO;
	self.subGoals = [NSMutableArray array];
	self.selectedTargets = [NSMutableSet set];
	
	return self;
}

- (AZRScheduledGoal *) scheduleSubGoal:(AZRLogicGoal *) goal {
	return [AZRScheduledGoal scheduleSubGoal:goal forParent:self];
}

+ (AZRScheduledGoal *) scheduleSubGoal:(AZRLogicGoal *) goal forParent:(AZRScheduledGoal *) parentScheduledGoal {
	AZRScheduledGoal *scheduledGoal = [AZRScheduledGoal new];
	
	[scheduledGoal setParent:parentScheduledGoal];
	if (parentScheduledGoal) {
		[(NSMutableArray *)parentScheduledGoal.subGoals insertObject:scheduledGoal atIndex:0];
		[scheduledGoal setRequestor:parentScheduledGoal.goal];
	}
	
	[scheduledGoal setGoal:goal];
	
	return scheduledGoal;
}

- (AZRScheduledGoal *) isSubGoal:(AZRLogicGoal *)goal {
	for (AZRScheduledGoal *subGoal in self.subGoals) {
    if (subGoal.goal == goal) {
			return subGoal;
		}
	}
	return nil;
}

#pragma mark - Select targets

- (AZRGoalTargetSelector *) selectTargetsKnownByActor:(AZRActor *)actor {
	AZRScheduledGoal *scheduled = self;
	while (scheduled && !scheduled.goal.targetSelector) {
		scheduled = scheduled.parent;
	}
	AZRGoalTargetSelector *selector = scheduled.goal.targetSelector;

	self.selectedTargets = selector ? [selector scanMemory:actor.knownObjects] : nil;
  return selector;
}

#pragma mark - Goal execution

// выполнение запланированной цели для `актора

- (BOOL) executeforActor:(AZRActor *)actor {
//	[AZRLogger log:NSStringFromClass([self class]) withMessage:@" -> %%{%@}", self.goal.name];
	BOOL achievedSubGoals = YES;
	// есть ли под-цели?
	if ([self.subGoals count]) {
		AZRScheduledGoal *lastSubGoal = self.subGoals[0];
		// есть под-цель, которая еще не выполнена
		if (![lastSubGoal isExecuted]) {
			// под-цель критична для `актора
			if (![lastSubGoal.goal isCriticalFor:actor]) {
				[lastSubGoal setAchieved:YES]; // нет - считаем ее выполненной и достигнутой
			} else
				return [lastSubGoal executeforActor:actor]; // да - выполняем ее
			
			return YES;
		}
//		else
//			achievedSubGoals = [lastSubGoal isAchieved];
	}
	
	// есть ли под-цели, которые нужно нужно выполнить прежде чем
	// текущая цель будет выполнена?
	AZRLogicGoal *goalToSchedule = [self pickGoalToScheduleForActor:actor achieved:&achievedSubGoals];
	if (goalToSchedule) {
		// планируем выполнение цели
		if (goalToSchedule == self.goal) {
			[self setAchieved:NO];
		} else {
			AZRScheduledGoal *scheduled;
			if ((scheduled = [self isSubGoal:goalToSchedule]) != nil) {
				[scheduled setExecuted:NO];
			} else
				[self scheduleSubGoal:goalToSchedule];
		}
	} else {
		[self setAchieved:achievedSubGoals]; // нет - считаем текущую цель выполненной
		[self setExecuted:YES];
	}
	
	return YES;
}

// выбор под-цели, выполнение которой нужно для достижения текущей цели
- (AZRLogicGoal *) pickGoalToScheduleForActor:(AZRActor *)actor achieved:(BOOL *)achieved {
	*achieved = YES;
	AZRLogicGoal *mainExecution = [self.goal execute:self forActor:actor achieved:achieved];
	
	if (mainExecution) {
		// plain sub-goals stil executing
		return mainExecution;
	}
	
	// nothing... search for conditional goals
	for (AZRLogicGoal *subGoal in [self.goal subGoalsWithOwnage:AZRLogicGoalOwnageTypeIfNode]) {
		AZRScheduledGoal *scheduledGoal;
    if ((scheduledGoal = [self isSubGoal:subGoal]) != nil)
			if ([scheduledGoal isExecuted]) {
				// propagate sub-goal achievement to parent
				*achieved = [scheduledGoal isAchieved];
				continue;
			}
		
		if (subGoal.fireIfNotAchieved ^ *achieved)
			return subGoal;
	}
	
	// if we come here, then there is no plains and no conditionals left
	// search for delayed goals
	for (AZRLogicGoal *subGoal in [self.goal subGoalsWithOwnage:AZRLogicGoalOwnageTypeWhenNode]) {
		AZRScheduledGoal *scheduledGoal;
    if ((scheduledGoal = [self isSubGoal:subGoal]) != nil)
			if ([scheduledGoal isExecuted]) {
				// propagate sub-goal achievement to parent
				*achieved = [scheduledGoal isAchieved];
				continue;
			}
		
		if (subGoal.fireIfNotAchieved ^ *achieved)
			return subGoal;
	}
	
	// oops, no more sub-goals or is it "blind" node?
	[self setExecuted:YES];
	return nil;
}

#pragma mark - achivedGoal

- (BOOL) isAchieved {
	return self->achievedGoal;
}

- (void) setAchieved:(BOOL)achieved {
	if (self->achievedGoal == achieved)
		return;
	
	self->achievedGoal = achieved;
	if (achieved)
		[self setExecuted:YES];
}

- (BOOL) isExecuted {
	return self->executedGoal;
}

- (void) setExecuted:(BOOL)executed {
	if (self->executedGoal == executed)
		return;
	
	self->executedGoal = executed;
	if (executed) {
		[(NSMutableArray *)self.subGoals removeAllObjects];
		self.parent = nil; // circular referencing =\.
	} else
		[self setAchieved:NO];
}

@end

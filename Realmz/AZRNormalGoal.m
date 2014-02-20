//
//  AZRNormalGoal.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRNormalGoal.h"

#import "AZRActor.h"
#import "AZRActorNeed.h"
#import "AZRScheduledGoal.h"
#import "AZRGoalCriticalCriteria.h"

@implementation AZRNormalGoal

- (BOOL) isCriticalFor:(AZRActor *)actor {
  // no criterias - critical by default
	if (![self.criterias count])
		return YES;
	
	for (AZRGoalCriticalCriteria *criteria in self.criterias) {
		AZRActorNeed *need = actor.needs[criteria.need];
		if (!need)
			continue;
			
    if ([criteria isCritical:need]) {
//			NSLog(@"[%@] is %@!", actor.description.name, need.name);
			return YES;
		}
	}
//	NSLog(@"[%@] %@ is not critical for [%@] at the moment...", self.name, self.criterias, actor.description.name);
	return NO;
}

- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved {
	*achieved = YES;
	
	NSArray *subGoals = [self subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode];
	for (AZRLogicGoal *subGoal in subGoals) {
		AZRScheduledGoal *scheduledGoal;
    if ((scheduledGoal = [scheduled isSubGoal:subGoal]) != nil) {
			if ([scheduledGoal isExecuted]) {
				if (![scheduledGoal isAchieved]) {
					*achieved = NO; // one of plain goals isn't achieved
					break;
				}
				
				continue;
			} else
				break; // there is scheduled, but not executed plain goal
		}
		
		//		[goals addObject:subGoal];
		// no priority mechanizm for now, just pick first
		return subGoal;
	}
	
	return nil;
}

// if normal goal has no plain sub-goal - it must be connected to another (global) goal
- (BOOL) isBlindNode {
	return ![[self subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode] count];
	//
	//	for (NSArray *ownage in [self.subGoals allValues]) {
	//    if ([ownage count]) {
	//			return NO;
	//		}
	//	}
	//
	//	return YES;
}

@end

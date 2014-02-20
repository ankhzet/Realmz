//
//  AZRActionGoal.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActionGoal.h"

#import "AZRObject+VisibleObject.h"
#import "AZRActor.h"
#import "AZRGoalTargetSelector.h"
#import "AZRActionIntent.h"
#import "AZRScheduledGoal.h"

@implementation AZRActionGoal

- (NSString *) typeIdentifier {
	return @"%";
}

- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved {
	*achieved = NO;
	AZRGoalTargetSelector *selector = [scheduled selectTargetsKnownByActor:actor];
	if (selector) {
		if (![[scheduled selectedTargets] count]) {
			[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Can't select object for action %@: actor doesn't know any [%@] objects, going to explore", scheduled.goal.name, selector];

			if (![actor scheduleGoal:@"discover" imperative:NO])
				*achieved = YES;
			return nil;
		}
	} else {
		[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Can't select object for action %@: can't aquire selector for goal", scheduled.goal.name];
		return nil;
	}
	
	CGPoint originPos = [actor targetedTo] ? [[actor targetedTo] CGPointValue] : [actor coordinates];
	NSArray *sorted = [[[scheduled selectedTargets] allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		float d1 = [obj1 sqrDistanceTo:originPos];
		float d2 = [obj2 sqrDistanceTo:originPos];
		return (d1 < d2) ? NSOrderedAscending : ((d1 > d2) ? NSOrderedDescending : NSOrderedSame);
	}];

	AZRActionIntent *intent = [AZRActionIntent new];
	[intent setAction:scheduled.goal.name];
	[intent setInitiator:actor];
	[intent setTarget:sorted[0]];
	
	*achieved = [intent execute];
	
	// no sub-nodes except conditional & delayed by default
	return (!*achieved) ? scheduled.goal : nil;
}

@end

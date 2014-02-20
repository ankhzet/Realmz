//
//  AZRStateGoal.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRStateGoal.h"
#import "AZRScheduledGoal.h"
#import "AZRObjectProperty.h"
#import "AZRActor.h"
#import "AZRObject+VisibleObject.h"
#import "AZRObject+PeasantActions.h"

@implementation AZRStateGoal

- (NSString *) typeIdentifier {
	return @"@";
}

- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved {
	*achieved = NO;

	do {
	if ([self.name isEqualToString:@"overloaded"]) {
		// resource, carried by peasant
		AZRObjectProperty *resources = [actor.properties objectForKey:AZRActorCommonPropertyBaggage];

		if (resources) {
			// is he carrying same resource, as he trying to chop?
			float carried = [(NSNumber *)(resources.vectorValue[1]) floatValue];
			float maxAmount = [actor floatProperty:AZRActorCommonPropertyCanCarry];
			if (carried >= maxAmount) {
				*achieved = YES;
				break;
			}
		}
		break;
	}
	
	if ([self.name isEqualToString:@"near"]) {
		AZRGoalTargetSelector *selector = [scheduled selectTargetsKnownByActor:actor];
		if (selector) {
			if (![[scheduled selectedTargets] count]) {
				[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Can't select object for state %@: actor doesn't know any [%@] objects", scheduled.goal.name, selector];
				break;
			}
		} else {
			[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Can't select object for state %@: can't aquire selector for goal", scheduled.goal.name];
			break;
		}

		CGPoint actorPos = [actor coordinates];
		NSArray *sorted = [[[scheduled selectedTargets] allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			float d1 = [obj1 sqrDistanceTo:actorPos];
			float d2 = [obj2 sqrDistanceTo:actorPos];
			return (d1 < d2) ? NSOrderedAscending : ((d1 > d2) ? NSOrderedDescending : NSOrderedSame);
		}];

		AZRObject *nearestObject = sorted[0];

		float r1 = [nearestObject radius];
		float r2 = [actor radius];

		*achieved = [actor sqrDistanceTo:[nearestObject coordinates]] <= SQR(r1 + r2 * 2);
		break;
	}
	} while (0);

//	if (*achieved) {
//		[AZRLogger log:NSStringFromClass([self class]) withMessage:@"%@ achieved @%@ state", [actor AZRClass], self.name];
//	}

	// no sub-nodes except conditional & delayed by default
	return nil;
}

@end

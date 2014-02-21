//
//  AZRPlanGoal.m
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRPlanGoal.h"

#import "AZRScheduledGoal.h"
#import "AZRActionGoal.h"

@implementation AZRPlanGoal

- (NSString *) typeIdentifier {
	return @"->";
}

- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved {
	
	// get root & parent action goal first
	AZRLogicGoal *root = scheduled.goal;
	AZRLogicGoal *action = nil;
	while (root.parent) {
		root = root.parent;
		if (root && !action) {//[root isKindOfClass:[AZRActionGoal class]]) {
			action = root;
		}
	}
	
	if (!action) {
		*achieved = NO;
		return nil;
	}
	*achieved = YES;

	AZRLogicGoal *findedAction;

	if ([action.name characterAtIndex:0] == ':') {
		NSString *blindGoalName = [action.name substringWithRange:NSMakeRange(1, [action.name length] - 2)];
		findedAction = [root findGoal:blindGoalName];
		if (findedAction) {
			findedAction = action;
		}
		[AZRLogger clearLog:nil];
	}

	if (!findedAction) {
		[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Don't know how to %%{%@}...", action.name];
		findedAction = [AZRActionGoal new];
		[findedAction setName:action.name];
		[findedAction setParent:scheduled.goal];
		return findedAction;
	}
	return findedAction;
}

@end

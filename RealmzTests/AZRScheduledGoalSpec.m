//
//  AZRScheduledGoalSpec.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRScheduledGoal.h"
#import "AZRActor.h"
#import "AZRNormalGoal.h"
#import "AZRStateGoal.h"
#import "AZRActionGoal.h"

SPEC_BEGIN(AZRScheduledGoalSpec)

describe(@"Testing goal-scheduling mechanizm", ^{
	AZRLogicGoal *requestedBy = [AZRLogicGoal new];
	AZRLogicGoal *goal = [AZRLogicGoal new];
	
	AZRScheduledGoal *parent = [AZRScheduledGoal new];
	parent.goal = requestedBy;
	AZRScheduledGoal *scheduled = [AZRScheduledGoal scheduleSubGoal:goal forParent:parent];
	
	it(@"should instantiate scheduled goals", ^{
		[[scheduled shouldNot] beNil];
		[[scheduled.parent should] equal:parent];
		[[theValue(scheduled.isAchieved) should] beNo];
		[[scheduled.subGoals should] haveCountOf:0];
	});
	
	it(@"should properly set requestor & goal", ^{
		[[scheduled.requestor should] equal:requestedBy];
		[[scheduled.goal should] equal:goal];
	});
	
	AZRActor *actor = (AZRActor *)[[[AZRObjectClassDescription alloc] initWithName:@"actor"] instantiateObject];
	
	it(@"executing of base goals should be ok", ^{
		BOOL executed = [scheduled executeforActor:actor];
		[[theValue(executed) should] beYes];
	});
	
	it(@"executing of state goals should success for proper states", ^{
		AZRScheduledGoal *scheduled = [AZRScheduledGoal scheduleSubGoal:[AZRNormalGoal new] forParent:nil];
		BOOL executed = [scheduled executeforActor:actor];
		[[theValue(executed) should] beYes];
	});
	
});

SPEC_END

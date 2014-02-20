//
//  AZRLogicGoalSpec.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRLogicGoal.h"
#import "AZRGoalCriticalCriteria.h"

SPEC_BEGIN(AZRLogicGoalSpec)

describe(@"Testing logic-goal", ^{
	NSString *goalName1 = @"goal1";
	NSString *goalName2 = @"goal2";
	NSString *goalName3 = @"goal3";
	
	AZRLogicGoal *goal = [AZRLogicGoal new];
	AZRLogicGoal *sub1 = [AZRLogicGoal newGoalWithName:goalName1];
	AZRLogicGoal *sub2 = [AZRLogicGoal newGoalWithName:goalName2];
	AZRLogicGoal *sub3 = [AZRLogicGoal newGoalWithName:goalName3];
	
	[sub1 setOwnage:AZRLogicGoalOwnageTypePlainNode];
	[sub2 setOwnage:AZRLogicGoalOwnageTypeIfNode];
	[sub3 setOwnage:AZRLogicGoalOwnageTypeWhenNode];
	
	it(@"should be properly instantiated", ^{
		[[goal shouldNot] beNil];
		[[sub1 shouldNot] beNil];
		[[sub2 shouldNot] beNil];
		[[sub3 shouldNot] beNil];
		
		[[sub1.name should] equal:goalName1];
		[[sub2.name should] equal:goalName2];
		[[sub3.name should] equal:goalName3];
		
		[[theValue(sub1.ownage) should] equal:theValue(AZRLogicGoalOwnageTypePlainNode)];
		[[theValue(sub2.ownage) should] equal:theValue(AZRLogicGoalOwnageTypeIfNode)];
		[[theValue(sub3.ownage) should] equal:theValue(AZRLogicGoalOwnageTypeWhenNode)];
	});
	
	it(@"should manage criterias", ^{
		[goal addCriteria:[AZRGoalCriticalCriteria criteriaForNeed:@"need1" warnOnlyIfCritical:YES]];
		[goal addCriteria:[AZRGoalCriticalCriteria criteriaForNeed:@"need2" warnOnlyIfCritical:NO]];
		[goal addCriteria:[AZRGoalCriticalCriteria criteriaForNeed:@"need3" warnOnlyIfCritical:YES]];
		
		[[goal.criterias should] haveCountOf:3];
	});
		
	it(@"shoul manage subgoals", ^{
		[goal addSubGoal:sub1];
		[goal addSubGoal:sub2];
		[goal addSubGoal:sub3];
		
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode] should] haveCountOf:1];
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypeIfNode] should] haveCountOf:1];
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypeWhenNode] should] haveCountOf:1];
		
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode][0] should] equal:sub1];
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypeIfNode][0] should] equal:sub2];
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypeWhenNode][0] should] equal:sub3];
	});
	
	it(@"should provide proper subgoals when requested", ^{
		[[[goal findGoal:goalName1] should] equal:sub1];
		[[[goal findGoal:@"goal1"] should] equal:sub1];
		
		// goal3 if when-goal, so it isn't visible from find method
		[[[goal findGoal:@"goal3"] should] beNil];
		[[[goal findGoal:@"goal4"] should] beNil];
	});
});

SPEC_END

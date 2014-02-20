//
//  AZRGoalTreeBuilderSpec.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRGoalTreeBuilder.h"
#import "AZRLogicParser.h"
#import "AZRLogicGoal.h"

SPEC_BEGIN(AZRGoalTreeBuilderSpec)

describe(@"Testing goal-tree builder", ^{
	AZRGoalTreeBuilder *builder = [AZRGoalTreeBuilder new];
	
	it(@"should fail for broken tree definitions", ^{
		AZRLogicGoal *goal;
		NSString *logicCode;
		logicCode = @"";
		goal = [builder buildTreeFromString:logicCode];
		[[goal should] beNil];
		
		logicCode = @"ываыа ыаваа";
		goal = [builder buildTreeFromString:logicCode];
		[[goal should] beNil];
		
		logicCode = @"for цель1 end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal should] beNil];
		
		logicCode = @"for цель1: /#thirsty/ end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal should] beNil];
		
		logicCode = @"for цель1: for цель2 end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal should] beNil];
	});
	
	it(@"should properly parse root node", ^{
		AZRLogicGoal *goal;
		NSString *logicCode;

		logicCode = @"for цель1: need под-цель1 end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal shouldNot] beNil];
		NSLog(@"%@", [goal description]);
		
		logicCode = @"for цель1: /#thirsty/ need под-цель1 end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal shouldNot] beNil];
		[[[goal criterias] should] haveCountOf:1];
		NSLog(@"%@", goal);
		
		logicCode = @"for цель1: /!#need1, #need2, !#need3/ need под-цель1: { if failed: reschedule need под-цель2 } end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal shouldNot] beNil];
		[[[goal criterias] should] haveCountOf:3];
		[[[goal subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode] should] haveCountOf:1];
		NSLog(@"%@", goal);

		logicCode = @"for цель1: need %действие1: { if achieved: need под-цель2 } end-logic";
		goal = [builder buildTreeFromString:logicCode];
		[[goal shouldNot] beNil];
		[[@([[goal criterias] count]) should] equal:@(0)];
		
		NSArray *subNodes = [goal subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode];
		[[@([subNodes count]) should] equal:@(1)];
		NSLog(@"%@", goal);
	
	});
	
});

SPEC_END

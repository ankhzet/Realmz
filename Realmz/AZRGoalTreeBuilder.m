//
//  AZRGoalTreeBuilder.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGoalTreeBuilder.h"

#import <ParseKit.h>
#import "AZRLogicParser.h"

#import "AZRLogicGoal.h"
#import "AZRNormalGoal.h"
#import "AZRStateGoal.h"
#import "AZRActionGoal.h"
#import "AZRNeedGoal.h"
#import "AZRPlanGoal.h"

#import "AZRSelectorBuilder.h"
#import "AZRGoalTargetSelector.h"
#import "AZRGoalCriticalCriteria.h"

#define _LOG_ASSEMBLY 0

#if _LOG_ASSEMBLY
#define LOG_ASSEMBLY() NSLog(@"\n\n%s\n%@\n\n", __PRETTY_FUNCTION__, a);
#else
#define LOG_ASSEMBLY() 

#endif

@interface AZRGoalTreeBuilder () {
	NSDictionary *goalClasses;
}
@end

@implementation AZRGoalTreeBuilder

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self->goalClasses =
	@{
		@"%": [AZRActionGoal class],
		@"@": [AZRStateGoal class],
		@"#": [AZRNeedGoal class], // TODO: need-goal implementation
		};
	
	return self;
}

- (AZRLogicGoal *) buildTreeFromLogicFile:(NSString *)source {
	NSURL *codeURL = [AZRLogicParser getLogicsFileURL:source fileType:AZRLogicsFileTypeLogic];
	if (!codeURL) {
		[AZRLogger log:nil withMessage:@"Can't find logics file for object logic [%@]", source];
		return nil;
	}
	
	NSError *error = nil;
	NSString *logicCode = [NSString stringWithContentsOfURL:codeURL encoding:NSUTF8StringEncoding error:&error];
	if (!logicCode) {
		[AZRLogger log:nil withMessage:@"Can't load logics file for object logic [%@]: %@", source, [error localizedDescription]];
		return nil;
	}
	
	return [self buildTreeFromString:logicCode];
}

- (AZRLogicGoal *) buildTreeFromString:(NSString *)source {
	
	PKParser *parser = [AZRLogicParser parserForGrammar:@"logic" assembler:self];
	
	NSError *error = nil;
	AZRLogicGoal *result = [parser parse:source error:&error];
	if (!result)
		[AZRLogger log:nil withMessage:@"Error parsing goal-tree: %@", [error localizedDescription]];
	else
		return result;
	
	return nil;
}

#pragma mark - Goal description

- (void)parser:(PKParser *)parser didMatchInherit:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	PKToken *token = [a pop];
	NSAssert([[token stringValue] isEqualToString:@";"], @"\";\" expected, but \"%@\" found", token);
	NSString *parentName = [(PKToken *)[a pop] stringValue];
	AZRLogicGoal *parent = [[AZRGoalTreeBuilder new] buildTreeFromLogicFile:parentName];
	
	[a push:parent];
	[a push:token];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchGlobal:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRLogicGoal *root = [a pop];
	if ([[[a pop] stringValue] isEqualToString:@";"]) {
		AZRLogicGoal *parent = [a pop];
		if (parent) {
			for (AZRLogicGoal *goal in [parent subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode]) {
				if (![root findGoal:goal.name ofClass:[goal class]])
					[root addSubGoal:goal];
			}
			[root connectBlindNodes:root];
		}
	}
	
 	[a push:root];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchGoalDescriptor:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	NSString *goalName = [(PKToken *)[a pop] stringValue];
	
	Class goalClass = [AZRNormalGoal class];
	if (![a isStackEmpty]) {
		id top = [a pop];
		if ([top isKindOfClass:[PKToken class]]) {
			Class t = self->goalClasses[[(PKToken *)top stringValue]];
			if (t)
				goalClass = t;
			else
				[a push:top];
		} else
			[a push:top];
	}
	
	AZRLogicGoal *goal = [goalClass new];
	[goal setName:goalName];
	
	[a push:goal];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchIsRoot:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRLogicGoal *goal = [a pop];
	[goal setOwnage:AZRLogicGoalOwnageTypeRootNode];
	[a push:goal];
	LOG_ASSEMBLY();
}


#pragma mark - Goal criterias

- (void)parser:(PKParser *)parser didMatchNormalCriteria:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	// multiple criterias - convert leftmost to set, if needed
	NSString *criteriaNeed = [(PKToken *)[a pop] stringValue];
	
	AZRGoalCriticalCriteria *criteria = [AZRGoalCriticalCriteria criteriaForNeed:criteriaNeed warnOnlyIfCritical:YES];
	
	[a push:criteria];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchImportantCriteria:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRGoalCriticalCriteria *criteria = [a pop];
	[criteria setWarnOnlyIfCritical:NO];
	[a push:criteria];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchAddCriteria:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	// multiple criterias - convert leftmost to set, if needed
	NSString *criteria = [a pop];
	
	NSMutableSet *criterias;
	id top = [a pop];
	if ([top isKindOfClass:[NSSet class]]) {
		criterias = top;
	} else
		criterias = [NSMutableSet setWithObject:top];
	
	[criterias addObject:criteria];
	
	[a push:criterias];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchCriterias:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	// if top token isn't a set - convert it
	
	NSMutableSet *criterias;
	id top = [a pop];
	if ([top isKindOfClass:[NSSet class]]) {
		criterias = top;
	} else
		criterias = [NSMutableSet setWithObject:top];
	
	PKToken *semi = [a pop];
	NSAssert([semi isKindOfClass:[PKToken class]] && [[semi stringValue] isEqualToString:@":"], @"semicolon expected after goal declaration, but %@ found", [semi stringValue]);
	
	AZRLogicGoal *goal = [a pop];
	for (AZRGoalCriticalCriteria *criteria in criterias) {
		[goal addCriteria:criteria];
	}
	[a push:goal];
	[a push:semi];
	LOG_ASSEMBLY();
}

#pragma mark - Goal selectors

- (void)parser:(PKParser *)parser didMatchSelector:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	// if top token isn't a set - convert it
	NSString *selectorDefinition = @"";
	PKToken *top;
	while (![[(top = [a pop]) stringValue] isEqualToString:@"["]) {
		selectorDefinition = [NSString stringWithFormat:@"%@ %@", [top stringValue], selectorDefinition];
	}
	
	AZRGoalTargetSelector *selector = [[AZRSelectorBuilder new] buildSelectorFromString:selectorDefinition];
	NSAssert(selector, @"selector parse failed");
	
	[a push:selector];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchGoalWithTarget:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRLogicGoal *goal;
	id top = [a pop];
	if ([top isKindOfClass:[AZRGoalTargetSelector class]]) {
		goal = [a pop];
		[goal setTargetSelector:top];
	} else
		goal = top;
	
	[a push:goal];
	LOG_ASSEMBLY();
}

#pragma mark - Sub-goals

- (void)parser:(PKParser *)parser didMatchSubGoals:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	NSMutableArray *goals = [NSMutableArray array];
	id top;
	while ([(top = [a pop]) isKindOfClass:[AZRLogicGoal class]]) {
		[goals insertObject:top atIndex:0];
	}

	NSAssert([top isKindOfClass:[PKToken class]] &&[[top stringValue] isEqualToString:@":"], @"semicolon expected after goal declaration, but %@ found", [top stringValue]);
	
	AZRLogicGoal *parentGoal = [a pop];
	
	for (AZRLogicGoal *goal in goals) {
    [parentGoal addSubGoal:goal];
	}
	
	[a push:parentGoal];
	
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchGoalSteps:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	NSMutableArray *goals = [NSMutableArray array];
	id top;
	while ([(top = [a pop]) isKindOfClass:[AZRLogicGoal class]]) {
		[goals insertObject:top atIndex:0];
	}

	NSAssert([top isKindOfClass:[PKToken class]] &&[[top stringValue] isEqualToString:@":"], @"semicolon expected after goal declaration, but %@ found", [top stringValue]);
	
	AZRLogicGoal *parentGoal = [a pop];
	
	for (AZRLogicGoal *goal in goals) {
    [parentGoal addSubGoal:goal];
	}
	
	[a push:parentGoal];
	
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchPlanGoal:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRLogicGoal *goal = [AZRPlanGoal new];
	[a push:goal];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchConditionalGoal:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRLogicGoal *goal = [a pop];
	[goal setOwnage:[(NSNumber *)[a pop] integerValue]];
	NSNumber *achieved = [a pop];
	[goal setFireIfNotAchieved:[achieved integerValue] ? NO : YES];
	[a push:goal];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchIfStep:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	[a push:@(AZRLogicGoalOwnageTypeIfNode)];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchWhenStep:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	[a push:@(AZRLogicGoalOwnageTypeWhenNode)];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchSuccessCondition:(PKAssembly *)a {
	[a push:@(YES)];
}

- (void)parser:(PKParser *)parser didMatchFailCondition:(PKAssembly *)a {
	[a push:@(NO)];
}

- (void)parser:(PKParser *)parser didMatchGoals:(PKAssembly *)a {
	AZRLogicGoal *goal;
	NSMutableArray *goals = [NSMutableArray array];
	while ([(goal = [a pop]) isKindOfClass:[AZRLogicGoal class]]) {
		[goals insertObject:goal atIndex:0];
	}
	
	if (goal) {
		[a push:goal];
	}
	
	AZRLogicGoal *root;
	if ([goals count] > 1) {
		root = [AZRLogicGoal new];
		for (AZRLogicGoal *goal in goals) {
			[root addSubGoal:goal];
		}
	} else
		root = goals[0];
	
	if ([goals count])
  	[root setName:[NSString stringWithFormat:@"root:%@", ((AZRLogicGoal*)goals[0]).name]];
	
	[root connectBlindNodes:root];
	
	[a push:root];
}

@end

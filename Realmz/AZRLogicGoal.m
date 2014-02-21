//
//  AZRLogicGoal.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRLogicGoal.h"

#import "AZRActor.h"
#import "AZRActorNeed.h"
#import "AZRScheduledGoal.h"
#import "AZRGoalCriticalCriteria.h"

@interface AZRLogicGoal ()
@property (nonatomic) NSDictionary *subGoals;
@end

@implementation AZRLogicGoal

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self.ownage = AZRLogicGoalOwnageTypePlainNode;
	self.fireIfNotAchieved = NO;
	self.subGoals =
	@{
		@(AZRLogicGoalOwnageTypePlainNode): [NSMutableArray array],
		@(AZRLogicGoalOwnageTypeIfNode): [NSMutableArray array],
		@(AZRLogicGoalOwnageTypeWhenNode): [NSMutableArray array],
		};
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	AZRLogicGoal *copiedGoal = [[self class] newGoalWithName:self.name];
	copiedGoal.ownage = self.ownage;
	copiedGoal.fireIfNotAchieved = self.fireIfNotAchieved;
	copiedGoal.targetSelector = self.targetSelector;
	copiedGoal.criterias = self.criterias;
	copiedGoal.parent = self.parent;
	for (NSArray *ownage in [self.subGoals allValues]) {
    for (AZRLogicGoal *subGoal in ownage) {
			[copiedGoal.subGoals[@(subGoal.ownage)] addObject:[subGoal copy]];
		}
	}
	return copiedGoal;
}

+ (id) newGoalWithName:(NSString *)goalName {
	AZRLogicGoal *goal = [self new];
	[goal setName:goalName];
	return goal;
}

- (NSString *) typeIdentifier {
	return @"";
}

- (void) dealloc {
	self.parent = nil;
}

#pragma mark - Sub-goals

- (void) addSubGoal:(AZRLogicGoal *)goal {
	NSMutableArray *ownage = self.subGoals[@(goal.ownage)];
	
	if (!ownage) {
		ownage = self.subGoals[@(AZRLogicGoalOwnageTypePlainNode)];
	}
	
	if (![ownage containsObject:goal]) {
		[ownage addObject:goal];
		[goal setParent:self];
	}
}

- (BOOL) replaceSubGoal:(AZRLogicGoal *)goal withGoal:(AZRLogicGoal *)newGoal {
	NSMutableArray *ownage = self.subGoals[@(goal.ownage)];
	if (!ownage) {
		return NO;
	}
	
	NSUInteger idx = [ownage indexOfObject:goal];
	[ownage replaceObjectAtIndex:idx withObject:newGoal];
	return YES;
}

- (NSArray *) subGoalsWithOwnage:(AZRLogicGoalOwnageType)ownage {
	return self.subGoals[@(ownage)];
}

- (AZRLogicGoal *) findGoal:(NSString *)goalName {
	for (AZRLogicGoal *goal in [self subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode]) {
    if ([goal.name isEqualToString:goalName]) {
			return goal;
		}
	}
	
	return nil;
}

- (AZRLogicGoal *) findGoal:(NSString *)goalName ofClass:(Class)goalClass {
	for (AZRLogicGoal *goal in [self subGoalsWithOwnage:AZRLogicGoalOwnageTypePlainNode]) {
		if ([goal isKindOfClass:goalClass] && [goal.name isEqualToString:goalName]) {
			return goal;
		}
	}
	
	return nil;
}

// goal must be conected to another global goal
- (BOOL) isBlindNode {
	return NO;
}

- (void) connectBlindNodes:(AZRLogicGoal *)rootNode {
	NSMutableDictionary *connections = [NSMutableDictionary dictionary];
	for (NSNumber *ownage in [self.subGoals allKeys]) {
		for (AZRLogicGoal *subGoal in self.subGoals[ownage]) {
			if (/*([ownage intValue] == AZRLogicGoalOwnageTypePlainNode) && */[subGoal isBlindNode]) {
				AZRLogicGoal *connectTo = [rootNode findGoal:subGoal.name ofClass:[subGoal class]];
				NSString *root = subGoal.name;
				AZRLogicGoal *node = subGoal.parent;
				while (node) {
					root = [NSString stringWithFormat:@"%@->%@", node.name, root];
					node = node.parent;
				}
				if (connectTo) {
					[connections setObject:@[subGoal, connectTo] forKey:subGoal.name];
					[AZRLogger log:nil withMessage:@"goal\n%@\n connected to %@ in ^{%@}", root, subGoal.name, rootNode.name];
				} else {
					[AZRLogger log:nil withMessage:@"goal\n%@\n is unknown for ^{%@}", root, rootNode.name];
				}
			}

			[subGoal connectBlindNodes:rootNode];
		}
	}
	
	for (NSArray *connection in [connections allValues]) {
    AZRLogicGoal *goal = connection[0];
		[goal addSubGoal:[connection[1] copy]];
		goal.name = [NSString stringWithFormat:@":%@:", goal.name];
	}
}

#pragma mark - Criterias

// критично ли выполнение текущей цели для `актора?
- (BOOL) isCriticalFor:(AZRActor *)actor {
	return YES; // по умолчанию - критично
}

- (void) addCriteria:(AZRGoalCriticalCriteria *)criteria {
	if (self.criterias)
		[(NSMutableSet *)self.criterias addObject:criteria];
	else
		self.criterias = [NSMutableSet setWithObject:criteria];
}

#pragma mark - Execution

- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved {
	*achieved = NO;
	return nil;
}

#pragma mark - Utils

- (NSString *) description {
	return [self descriptionTabbed:@""];
}

- (NSString *) descriptionTabbed:(NSString *)tabbed {
	NSString *ifwhen = @"need";
	NSString* achieved[] = {@"achieved,", @"failed,"};
	
	if (self.ownage != AZRLogicGoalOwnageTypePlainNode) {
		switch (self.ownage) {
			case AZRLogicGoalOwnageTypeIfNode:
				ifwhen = [NSString stringWithFormat:@"if %@", achieved[self.fireIfNotAchieved]];
				break;
			case AZRLogicGoalOwnageTypeWhenNode:
				ifwhen = [NSString stringWithFormat:@"when %@", achieved[self.fireIfNotAchieved]];
				break;
			default:
				break;
		}
	}
	
	NSString *selector;
	if (self.targetSelector) {
		selector = [NSString stringWithFormat:@" (%@)", self.targetSelector];
	} else
		selector = @"";
	
	NSString *criterias = @"";
	if ([self.criterias count]) {
		for (AZRGoalCriticalCriteria *criteria in self.criterias) {
			criterias = [NSString stringWithFormat:@"%@/%@", criterias, criteria];
		}
		criterias = [NSString stringWithFormat:@"%@/", criterias];
	}
	
	NSString *subGoals = @"";
	NSString *subtab = @"";
	NSString *tab = [NSString stringWithFormat:@"%@\t", tabbed];
	int i = 0;
	for (NSArray *goals in [self.subGoals allValues]) {
		if ([goals count]) {
			for (AZRLogicGoal *subGoal in goals) {
				i++;
				subGoals = [NSString stringWithFormat:@"%@\n%@", subGoals, [subGoal descriptionTabbed:tab]];
			}
			subGoals = [NSString stringWithFormat:@"%@\n%@", subGoals, tabbed];
		}
	}
	if (i)	subtab = [NSString stringWithFormat:@"\n%@for ", tab];
	
	NSString *name = self.name ? self.name : @"reschedule";
	return [NSString stringWithFormat:@"%@%@ %@{%@%@%@%@%@}", tabbed, ifwhen, [self typeIdentifier], subtab, name, criterias, selector, subGoals];
}

@end

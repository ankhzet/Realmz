//
//  AZRSelectorBuilder.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGoalTargetSelectorLoader.h"

#import <ParseKit/ParseKit.h>
#import "AZRGoalTargetSelector.h"
#import "AZRGoalPropertySelector.h"

#define _LOG_ASSEMBLY 0

#if _LOG_ASSEMBLY
#define LOG_ASSEMBLY() NSLog(@"\n\n%s\n%@\n\n", __PRETTY_FUNCTION__, a);
#else
#define LOG_ASSEMBLY() do {} while (0)
#endif


@interface AZRGoalTargetSelectorLoader ()
{
  NSDictionary *comparators;
}
@end

@implementation AZRGoalTargetSelectorLoader

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self->comparators =
	@{
		@"<>": @(AZRPropertySelectorComparatorLess | AZRPropertySelectorComparatorGreater),
		@"=": @(AZRPropertySelectorComparatorEqual),
		@"<": @(AZRPropertySelectorComparatorLess),
		@">": @(AZRPropertySelectorComparatorGreater),
		@"<=": @(AZRPropertySelectorComparatorLess | AZRPropertySelectorComparatorEqual),
		@">=": @(AZRPropertySelectorComparatorGreater | AZRPropertySelectorComparatorEqual),
		};
	
	return self;
}

-(NSString *)grammar {
	return @"target-selector";
}

#pragma mark - Parser proto

- (void)parser:(PKParser *)parser didMatchObject:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRGoalTargetSelector *selector = [AZRGoalTargetSelector new];
	id top = [a pop];
	// is it a '*' symbol?
	if (![top isKindOfClass:[PKToken class]]) {
		// no, property specified
		[selector setPropertySelector:top];
		top = [a pop]; // popping that '*' out
	}
	[a push:selector];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchProperty:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	PKToken *token = [a pop];
	AZRGoalPropertySelector *property = [[AZRGoalPropertySelector alloc] initWithPropertyName:[token stringValue]];
	[a push:property];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchEqu:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *equ = [[a pop] stringValue];
	[a push:self->comparators[equ]];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchComparator:(PKAssembly *)a {
	LOG_ASSEMBLY();
	float right = [(PKToken *)[a pop] floatValue];
	NSNumber *equ = [a pop];
	AZRGoalPropertySelector *property = [a pop];
	[property setValue:right];
	[property setComparator:[equ integerValue]];
	[a push:property];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchSelector:(PKAssembly *)a {
	LOG_ASSEMBLY();
	AZRGoalTargetSelector *selector;
	id top = [a pop];
	
	// is filters there?
	if ([top isKindOfClass:[NSArray class]]) {
		selector = [a pop];
		[selector setFilters:(NSArray *)top];
	} else
		selector = top;
	
	[a push:selector];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchFilters:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	NSArray *filters;
	
	id top = [a pop];
	if ([top isKindOfClass:[NSArray class]]) {
		filters = top;
	} else
		filters = [NSMutableArray arrayWithObject:top];
	
	[a push:filters];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchInverse:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRGoalTargetSelector *selector = [a pop];
	[selector setNegative:YES];
	[a push:selector];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchAdditional:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRGoalTargetSelector *right = [a pop];
	id left = [a pop];
	NSMutableArray *filters;
	if ([left isKindOfClass:[AZRGoalTargetSelector class]]) {
		filters = [NSMutableArray arrayWithObject:left];
	} else
		filters = left;
	
	[filters addObject:right];
	[a push:filters];
	
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchRequired:(PKAssembly *)a
{
	LOG_ASSEMBLY();
	AZRGoalTargetSelector *selector = [a pop];
	[selector setMatchAlways:YES];
	[a push:selector];
	LOG_ASSEMBLY();
}


@end

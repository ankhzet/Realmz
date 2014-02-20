//
//  AZRGoalTargetSelector.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGoalTargetSelector.h"

#import "AZRObject.h"
#import "AZRGoalPropertySelector.h"
#import "AZRActorObjectsMemory.h"

@implementation AZRGoalTargetSelector

- (void) addFilter:(AZRGoalTargetSelector *) filter {
	if (!self.filters) {
		self.filters = [NSMutableArray array];
//		[filter setMatchAlways:YES];
	}
	
	[(NSMutableArray *)self.filters addObject:filter];
}

- (NSSet *) filterObjects:(NSSet *)targets asKnownBy: (AZRActorObjectsMemory *) memory {
	NSMutableSet *fetched = targets ? [NSMutableSet set] : nil;
	
	for (AZRObject *object in targets) {
		if ([self objectMatch:object asKnownBy:memory]) {
			[fetched addObject:object];
		}
	}

	return fetched;
}

- (NSSet *) scanMemory: (AZRActorObjectsMemory *) memory {
	NSMutableSet *fetched = [NSMutableSet set];
	for (NSSet *group in [[memory allMemory] allValues]) {
    [fetched addObjectsFromArray:[[self filterObjects:group asKnownBy:memory] allObjects]];
	}
	return fetched;
}

- (BOOL) objectMatch:(AZRObject *)object asKnownBy: (AZRActorObjectsMemory *) memory {
	if (self.propertySelector) {
		BOOL isKnownProperty = [memory knownProperty:self.propertySelector.property forObject:object];
		if (!isKnownProperty) {
			// if we don't know real property state - assume any comparison as failed
			// so, for unknow property p1 selectors like (not *p1), (*p1 > 1) and (not *p1 > 1)
			// will return YES, NO, YES
			return NO ^ self.negative; // or !self.negative
		}
		
		// if property is known and comparator is set:
		// comparator matches - if selector is in negotation mode (not *p1 > 1),
		// then all comparison fails (treat as (*p <= 1)), so return NO, else - check sub-selectors
		// if comparator fails - when selector is in negotation mode, then selector itself matches
		// (*p1 > 1 = NO, then *p1 <= 1 = YES) and so on...
		// comparision | negotation | action
		// success     | NO         | check subs  1 ^ 0 = 1
		// failed      | NO         | return NO   0 ^ 0 = 0
		// success     | YES        | return NO   1 ^ 1 = 0
		// failed      | YES        | check subs  0 ^ 1 = 1
		
		BOOL hasComparator = self.propertySelector.comparator;
		BOOL comparatorMatches = hasComparator ? [self.propertySelector matchProperty:object.properties[self.propertySelector.property]] : YES;
		
		if (hasComparator && !(comparatorMatches ^ self.negative))
			return NO;
	}
	
	if (self.filters) {
		BOOL match = YES;
		BOOL first = YES;
		for (AZRGoalTargetSelector *filter in self.filters) {
			BOOL matchFilter = [filter objectMatch:object asKnownBy:memory];
			if (filter.matchAlways || first) {
				match &= matchFilter;
			} else
				match |= matchFilter;
			
			if (!match)
				break;
			
			first = NO;
		}
		return match ^ self.negative;
	}

	return YES ^ self.negative;
	// can be also written as "return !self.negative", but not represents the meaning of return value
}

- (NSString *) description {
	NSString *and = (self.matchAlways) ? @"and " : @"";
	NSString *not = (self.negative) ? @"not " : @"";
	NSString *filters = nil;
	if ([self.filters count]) {
		for (AZRGoalTargetSelector *s in self.filters) {
			filters = filters ? [NSString stringWithFormat:@"%@, %@", filters, s] : [s description];
		}
		filters = [NSString stringWithFormat:@" (%@)", filters];
	} else
		filters = @"";
	
	NSString *property = self.propertySelector ? [self.propertySelector description] : @"";
	return [NSString stringWithFormat:@"%@%@*%@%@", and, not, property, filters];
}

@end

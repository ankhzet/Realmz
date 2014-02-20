//
//  AZRGoalPropertySelector.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGoalPropertySelector.h"

#import "AZRObjectProperty.h"

#define STATIC_COMPARATOR(_name, _comparator) static AZRPropertySelectorComparatorBlock _name = ^BOOL(float left, float right) {return _comparator;}

typedef BOOL (^AZRPropertySelectorComparatorBlock)(float, float);

@interface AZRGoalPropertySelector ()
{
	AZRPropertySelectorComparatorBlock comparatorBlock;
}

@end

@implementation AZRGoalPropertySelector
@synthesize comparator = _comparator;


- (id) initWithPropertyName: (NSString *) name {
	if (!(self = [super init]))
		return nil;
	
	self.property = name;
	self.value = 0.0;
	self.comparator = 0;
	
	return self;
}

- (void) setComparator:(AZRPropertySelectorComparator)comparator {
	if (_comparator == comparator)
		return;
	
	_comparator = comparator;
	
	STATIC_COMPARATOR(equalComparator, left == right);
	STATIC_COMPARATOR(lessComparator, left < right);
	STATIC_COMPARATOR(greaterComparator, left > right);
	STATIC_COMPARATOR(lessEqualComparator, left <= right);
	STATIC_COMPARATOR(greaterEqualComparator, left >= right);
	STATIC_COMPARATOR(notEqualComparator, left != right);
	
	BOOL less = TEST_BIT(comparator, AZRPropertySelectorComparatorLess);
	BOOL greater = TEST_BIT(comparator, AZRPropertySelectorComparatorGreater);
	BOOL equal = TEST_BIT(comparator, AZRPropertySelectorComparatorEqual);
	
	if (equal) {
		if (less) {
			self->comparatorBlock = lessEqualComparator;
		} else if (greater) {
			self->comparatorBlock = greaterEqualComparator;
		} else
			self->comparatorBlock = equalComparator;
	} else
		if (less & greater) {
			self->comparatorBlock = notEqualComparator;
		} else if (less) {
			self->comparatorBlock = lessComparator;
		} else
			self->comparatorBlock = greaterComparator;
}

- (AZRPropertySelectorComparator)comparator {
	return _comparator;
}

- (BOOL) matchProperty:(AZRObjectProperty *)property {
	return self->comparatorBlock([property.numberValue floatValue], self.value);
}

- (NSString *) description {
	NSString *value;
	if (self.comparator) {
		NSString *less = TEST_BIT(self.comparator, AZRPropertySelectorComparatorLess) ? @"<" : @"";
		NSString *greater = TEST_BIT(self.comparator, AZRPropertySelectorComparatorGreater) ? @">" : @"";
		NSString *equal = TEST_BIT(self.comparator, AZRPropertySelectorComparatorEqual) ? @"=" : @"";
		
		NSString *comparator = [NSString stringWithFormat:@"%@%@%@", less, greater, equal];
		value = [NSString stringWithFormat:@" %@ %@", comparator, @(self.value)];
	} else
		value = @"";
	
	
	return [NSString stringWithFormat:@"[%@%@]", self.property, value];
}

@end

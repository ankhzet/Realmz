//
//  AZRGoalPropertySelectorSpec.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRGoalPropertySelector.h"
#import "AZRObjectProperty.h"

SPEC_BEGIN(AZRGoalPropertySelectorSpec)

describe(@"Testing property selector", ^{
	__block AZRGoalPropertySelector *selector = [[AZRGoalPropertySelector alloc] initWithPropertyName:@"property"];
	
	it(@"should have property name set", ^{
		[[selector.property should] equal:@"property"];
	});
	
	AZRObjectProperty *p = [AZRObjectProperty new];
	[p setName:@"property"];
	[p setNumberValue:@(0.5)];
	
	it(@"should handle '<' comparator", ^{
		AZRPropertySelectorComparator comparator = AZRPropertySelectorComparatorLess;
		[selector setComparator:comparator];
		[[theValue(selector.comparator) should] equal:theValue(comparator)];
		
		[selector setValue:0.0];
		[[theValue([selector matchProperty:p]) should] beNo];
		[selector setValue:1.0];
		[[theValue([selector matchProperty:p]) should] beYes];
	});
	
	it(@"should handle '<=' comparator", ^{
		AZRPropertySelectorComparator comparator = AZRPropertySelectorComparatorLess | AZRPropertySelectorComparatorEqual;
		[selector setComparator:comparator];
		[[theValue(selector.comparator) should] equal:theValue(comparator)];
		
		[selector setValue:0.0];
		[[theValue([selector matchProperty:p]) should] beNo];
		[selector setValue:1.0];
		[[theValue([selector matchProperty:p]) should] beYes];
		[selector setValue:0.5];
		[[theValue([selector matchProperty:p]) should] beYes];
	});
	
	it(@"should handle '>' comparator", ^{
		AZRPropertySelectorComparator comparator = AZRPropertySelectorComparatorGreater;
		[selector setComparator:comparator];
		[[theValue(selector.comparator) should] equal:theValue(comparator)];
		
		[selector setValue:0.0];
		[[theValue([selector matchProperty:p]) should] beYes];
		[selector setValue:1.0];
		[[theValue([selector matchProperty:p]) should] beNo];
	});
	
	it(@"should handle '>=' comparator", ^{
		AZRPropertySelectorComparator comparator = AZRPropertySelectorComparatorGreater | AZRPropertySelectorComparatorEqual;
		[selector setComparator:comparator];
		[[theValue(selector.comparator) should] equal:theValue(comparator)];
		
		[selector setValue:0.0];
		[[theValue([selector matchProperty:p]) should] beYes];
		[selector setValue:1.0];
		[[theValue([selector matchProperty:p]) should] beNo];
		[selector setValue:0.5];
		[[theValue([selector matchProperty:p]) should] beYes];
	});
	
	it(@"should handle '=' comparator", ^{
		AZRPropertySelectorComparator comparator = AZRPropertySelectorComparatorEqual;
		[selector setComparator:comparator];
		[[theValue(selector.comparator) should] equal:theValue(comparator)];
		
		[selector setValue:0.0];
		[[theValue([selector matchProperty:p]) should] beNo];
		[selector setValue:1.0];
		[[theValue([selector matchProperty:p]) should] beNo];
		[selector setValue:0.5];
		[[theValue([selector matchProperty:p]) should] beYes];
	});
	
	it(@"should handle '<>' comparator", ^{
		AZRPropertySelectorComparator comparator = AZRPropertySelectorComparatorGreater | AZRPropertySelectorComparatorLess;
		[selector setComparator:comparator];
		[[theValue(selector.comparator) should] equal:theValue(comparator)];
		
		[selector setValue:0.0];
		[[theValue([selector matchProperty:p]) should] beYes];
		[selector setValue:1.0];
		[[theValue([selector matchProperty:p]) should] beYes];
		[selector setValue:0.5];
		[[theValue([selector matchProperty:p]) should] beNo];
	});
	
});

SPEC_END

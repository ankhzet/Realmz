//
//  AZRTechnology+Spec.m
//  Realmz
//  Spec for AZRTechnology
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRTechTree.h"
#import "AZRTechnology.h"
#import "AZRTechnology+Protected.h"

SPEC_BEGIN(AZRTechnology_Spec)

describe(@"AZRTechnology", ^{
	static NSString *techName1 = @"tech1";
	static NSString *techName2 = @"tech2";
	static NSString *techName3 = @"tech3";

	AZRTechTree *techTree = [AZRTechTree techTree];

	it(@"should instantiate", ^{
		AZRTechnology *tech = [AZRTechnology technology:techName1 inTechTree:techTree];
		[[tech shouldNot] beNil];
		[[tech.techTree shouldNot] beNil];
		[[tech.techTree should] equal:techTree];

		// adding tech with same name should return already added instance
		AZRTechnology *tech2 = [AZRTechnology technology:techName1 inTechTree:techTree];
		[[tech2 shouldNot] beNil];
		[[tech2 should] equal:tech];
	});

	it(@"should handle required techs & fetch dependent techs", ^{
		AZRTechnology *tech1 = [AZRTechnology technology:techName1 inTechTree:techTree];
		AZRTechnology *tech2 = [AZRTechnology technology:techName2 inTechTree:techTree];

		AZRTechnology *required = [tech2 addRequired:techName1];
		[[required shouldNot] beNil];
		[[required should] equal:tech1];

		NSArray *dependent1 = [tech1 fetchDependent];
		[[dependent1 shouldNot] beNil];
		[[dependent1 should] haveCountOf:1];
		[[theValue([dependent1 containsObject:tech2]) should] beYes];

		// tech should not state as required more than once for each addition
		[tech2 addRequired:techName1];
		NSArray *dependent2 = [tech1 fetchDependent];
		[[dependent2 shouldNot] beNil];
		[[dependent2 should] haveCountOf:1];
	});

	it(@"should calc state based on dependencies", ^{
		AZRTechTree *techTree = [AZRTechTree techTree]; // re-creating

		AZRTechnology *tech1 = [AZRTechnology technology:techName1 inTechTree:techTree];
		AZRTechnology *tech2 = [AZRTechnology technology:techName2 inTechTree:techTree];
		AZRTechnology *tech3 = [AZRTechnology technology:techName3 inTechTree:techTree];

		[[theValue([tech2 isImplementable]) should] beYes];

		[tech1 stub:@selector(isImplemented) andReturn:theValue(NO)];

		[tech2 addRequired:techName1];
		[[theValue([tech2 isImplementable]) should] beNo];
		[tech3 addRequired:techName2];
		[[theValue([tech3 isImplementable]) should] beNo]; // chain update

		[tech1 stub:@selector(isImplemented) andReturn:theValue(YES)];
		[tech2 dependencyImplemented:tech1];
		[[theValue([tech2 isImplementable]) should] beYes];
		[[theValue([tech3 isImplementable]) should] beYes]; // chain update
	});

	it(@"should manage gains & drains", ^{
		
	});
});

SPEC_END

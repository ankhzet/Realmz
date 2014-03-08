//
//  AZRTechnologySpec.m
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
#import "AZRTechResource.h"

SPEC_BEGIN(AZRTechnologySpec)

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

		[[theValue([tech isImplementable]) should] beYes];
		[[theValue([tech isImplemented]) should] beNo];
		[[theValue([tech isInProcess]) should] beNo];
		[[theValue([tech isUnavailable]) should] beNo];

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

		[[theValue([tech1 isImplementable]) should] beYes];
		[[theValue([tech2 isImplementable]) should] beYes];
		[[theValue([tech3 isImplementable]) should] beYes];

		[[theValue([tech1 isImplemented]) should] beNo];
		[[theValue([tech2 isImplemented]) should] beNo];
		[[theValue([tech3 isImplemented]) should] beNo];

		[tech2 addRequired:techName1];
		[tech3 addRequired:techName2];
		[[theValue([tech2 isImplementable]) should] beNo]; // tech1 (required) is not-implemented
		[[theValue([tech3 isImplementable]) should] beNo]; // tech2 (required) is not-implemented

		// simulate implementation state propagation
		[tech1 stub:@selector(isImplemented) andReturn:theValue(YES)];
		[tech2 dependency:tech1 implemented:YES];
		[[theValue([tech2 isImplementable]) should] beYes]; // tech1 (required) is implemented now
		[[theValue([tech3 isImplementable]) should] beNo]; // tech2 (required) is stil not-implemented

		[tech2 stub:@selector(isImplemented) andReturn:theValue(YES)];
		[tech3 dependency:tech2 implemented:YES];
		[[theValue([tech3 isImplementable]) should] beYes]; // tech2 (required) is implemented now
		[tech3 dependency:tech2 implemented:NO];
		[[theValue([tech3 isImplementable]) should] beNo]; // tech2 (required) is implemented now
	});

	it(@"should manage drains", ^{
		AZRTechnology *tech = [AZRTechnology technology:techName1 inTechTree:techTree];

		AZRTechResource *res1 = [tech addDrain:AZRTechResourceTypeResource];
		AZRTechResource *res2 = [tech addDrain:AZRTechResourceTypeUnit];
		AZRTechResource *res3 = [tech addDrain:AZRTechResourceTypeUnit];
		AZRTechResource *res4 = [tech addDrain:AZRTechResourceTypeTech];

		[[res1 shouldNot] beNil];
		[[res2 shouldNot] beNil];
		[[res3 shouldNot] beNil];
		[[res4 shouldNot] beNil];

		res1.resource = @"resource1";
		res1.handler = AZRResourceHandlerNormal;
		res1.amount = 100;

		res2.resource = @"resource2";
		res2.handler = AZRResourceHandlerReplacer;

		res3.resource = @"resource2";
		res3.handler = AZRResourceHandlerTargeted;

		res4.resource = @"resource4";
		res4.handler = AZRResourceHandlerNormal;

		NSArray *resources1 = [tech getDrained:AZRTechResourceTypeResource];
		[[resources1 shouldNot] beNil];
		[[resources1 should] haveCountOf:1];

		NSArray *resources2 = [tech getDrained:AZRTechResourceTypeTech];
		[[resources2 shouldNot] beNil];
		[[resources2 should] haveCountOf:1];

		NSArray *resources3 = [tech getDrained:AZRTechResourceTypeUnit];
		[[resources3 shouldNot] beNil];
		[[resources3 should] haveCountOf:2];
	});

	it(@"should drain resources on pre-implement", ^{
		AZRTechnology *tech = [AZRTechnology technology:techName2 inTechTree:techTree];
		AZRTechResource *res1 = [tech addDrain:AZRTechResourceTypeResource];
		AZRTechResource *res2 = [tech addDrain:AZRTechResourceTypeUnit];
		AZRTechResource *res3 = [tech addDrain:AZRTechResourceTypeUnit];
		AZRTechResource *res4 = [tech addDrain:AZRTechResourceTypeTech];

		res3.handler = AZRResourceHandlerTargeted;

		id target = @(0);
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res1,nil];
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res2,nil];
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(NO) withArguments:res3,nil];
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res4,nil];

		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res1,target];
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res2,target];
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res3,target];
		[[techTree should] receive:@selector(drainResource:targeted:) andReturn:theValue(YES) withArguments:res4,target];

		[[theValue([tech preImplement:nil]) should] beNo];
		[[theValue([tech preImplement:target]) should] beYes];
	});

	it(@"should not calc progress, if not in-process", ^{
		AZRTechnology *tech = [AZRTechnology technology:techName1 inTechTree:techTree];

		NSTimeInterval lastTick = [NSDate timeIntervalSinceReferenceDate];

		[[tech should] receive:@selector(calcAvailability)];
		[[tech shouldNot] receive:@selector(processProgress:) withArguments:theValue(lastTick)];
		[tech stub:@selector(isInProcess) andReturn:theValue(NO)];
		[tech process:lastTick];
	});
	it(@"should calc progress, if in-process", ^{
		AZRTechnology *tech = [AZRTechnology technology:techName2 inTechTree:techTree];

		NSTimeInterval lastTick = [NSDate timeIntervalSinceReferenceDate];

		[[tech should] receive:@selector(calcAvailability)];
		[[tech should] receive:@selector(processProgress:) withArguments:theValue(lastTick)];
		[tech stub:@selector(isInProcess) andReturn:theValue(YES)];
		[tech process:lastTick];
	});

	it(@"should update dependant techs state on 'implemented' state", ^{
		AZRTechTree *techTree = [AZRTechTree techTree];
		AZRTechnology *tech1 = [AZRTechnology technology:techName1 inTechTree:techTree];
		AZRTechnology *tech2 = [AZRTechnology technology:techName2 inTechTree:techTree];

		[tech2 addRequired:tech1.name];


		[[theValue([tech1 isImplementable]) should] beYes];
		[[theValue([tech1 isImplemented]) should] beNo];

		[[tech2 should] receive:@selector(dependency:implemented:) withArguments:tech1,theValue(YES)];
		[tech1 forceImplemented:YES];
		[[theValue([tech1 isImplementable]) should] beNo];
		[[theValue([tech1 isImplemented]) should] beYes];

		[[tech2 should] receive:@selector(dependency:implemented:) withArguments:tech1,theValue(NO)];
		[tech1 forceImplemented:NO];
		[[theValue([tech1 isImplementable]) should] beYes];
		[[theValue([tech1 isImplemented]) should] beNo];
	});

	context(@"availability", ^{
		AZRTechTree *techTree = [AZRTechTree techTree];
		AZRTechnology *tech1 = [AZRTechnology technology:techName1 inTechTree:techTree];
		AZRTechnology *tech2 = [AZRTechnology technology:techName2 inTechTree:techTree];
		AZRTechnology *tech3 = [AZRTechnology technology:techName3 inTechTree:techTree];
		it(@"should be in 'unavailable' state if iteration limit reached", ^{
			tech1.multiple = 0;
			AZRTechResource *resource = [tech1 addDrain:AZRTechResourceTypeResource];
			[[techTree should] receive:@selector(isResourceAvailable:) andReturn:theValue(YES) withArguments:resource];
			[[theValue([tech1 isUnavailable]) should] beNo];
			[[theValue([tech1 calcAvailability]) should] beYes];

			tech1.multiple = 1;
			[[tech1.iterations should] receive:@selector(count) andReturn:theValue(1)];
			[[theValue([tech1 calcAvailability]) should] beNo];
			[[theValue([tech1 isUnavailable]) should] beYes];
		});
		it(@"should ask tech manager (techTree) for self availability", ^{
			AZRTechResource *resource = [tech2 addDrain:AZRTechResourceTypeResource];
			[[techTree should] receive:@selector(isResourceAvailable:) andReturn:theValue(YES) withArguments:resource];
			[[theValue([tech2 calcAvailability]) should] beYes];

			AZRTechResource *resource2 = [tech3 addDrain:AZRTechResourceTypeResource];
			[[techTree should] receive:@selector(isResourceAvailable:) andReturn:theValue(NO) withArguments:resource2];
			[[theValue([tech3 calcAvailability]) should] beNo];
			[[theValue([tech3 isUnavailable]) should] beYes];
		});
	});

	context(@"implementation", ^{
		AZRTechTree *techTree = [AZRTechTree techTree];
		AZRTechnology *tech = [AZRTechnology technology:techName1 inTechTree:techTree];

		it(@"should calc availability on implementation and return NO if not-available", ^{
			[[tech should] receive:@selector(calcAvailability) andReturn:theValue(NO)];
			[[theValue([tech implement:YES withTarget:nil]) should] beNo];
		});
		it(@"should force implementation if available", ^{
			[[theValue([tech isInProcess]) should] beNo];
			[[tech.iterations should] haveCountOf:0];
			[[tech should] receive:@selector(calcAvailability) andReturn:theValue(YES) withCount:3];
			[[tech should] receive:@selector(preImplement:) andReturn:theValue(YES) withCount:3 arguments:nil];

			[[theValue([tech implement:YES withTarget:nil]) should] beYes];
			[[theValue([tech isInProcess]) should] beYes];
			[[tech.iterations should] haveCountOf:1];

			[[theValue([tech implement:YES withTarget:nil]) should] beYes];
			[[tech.iterations should] haveCountOf:2];

			[[theValue([tech implement:YES withTarget:nil]) should] beYes];
			[[tech.iterations should] haveCountOf:3];
		});
	});
});

SPEC_END

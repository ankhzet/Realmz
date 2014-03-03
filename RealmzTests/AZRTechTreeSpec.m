//
//  AZRTechTreeSpec.m
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRTechTree.h"
#import "AZRTechnology.h"

SPEC_BEGIN(AZRTechTreeSpec)

describe(@"Testing tech tree", ^{
	__block AZRTechTree *techTree;
	static NSString *techName1 = @"tech1";
	static NSString *techName2 = @"tech2";
	static NSString *techName3 = @"tech3";

	it(@"should instantiate", ^{
		techTree = [AZRTechTree techTree];
		[[techTree shouldNot] beNil];
	});

	it(@"should manage techs", ^{
		id tech1 = [AZRTechnology nullMock];
		[[tech1 should] receive:@selector(name) andReturn:techName1 withCountAtLeast:0];
		id tech2 = [AZRTechnology nullMock];
		[[tech2 should] receive:@selector(name) andReturn:techName2 withCountAtLeast:0];
		id tech3 = [AZRTechnology nullMock];
		[[tech3 should] receive:@selector(name) andReturn:techName3 withCountAtLeast:0];

		[techTree addTech:tech1];
		[techTree addTech:tech2];
		[techTree addTech:tech3];

		[[[techTree techNamed:techName1] shouldNot] beNil];
		[[[techTree techNamed:techName2] shouldNot] beNil];
		[[[techTree techNamed:techName3] shouldNot] beNil];
		[[[techTree techNamed:techName1] should] equal:tech1];
		[[[techTree techNamed:techName2] should] equal:tech2];
		[[[techTree techNamed:techName3] should] equal:tech3];
		[[[techTree techNamed:techName1] shouldNot] equal:tech2];

		AZRTechnology *removed = [techTree removeTech:techName1];
		[[removed shouldNot] beNil];
		[[removed should] equal:tech1];
		[[[techTree techNamed:techName1] should] beNil];

		[[techTree.technologies should] haveCountOf:2];
		[techTree addTech:tech1];
		[techTree addTech:tech1];
		[techTree addTech:tech2];
		[[techTree.technologies should] haveCountOf:3];
	});

	it(@"should fetch tech dependencies", ^{
		AZRTechnology *tech1 = [techTree techNamed:techName1];
		AZRTechnology *tech2 = [techTree techNamed:techName2];
		AZRTechnology *tech3 = [techTree techNamed:techName3];

		[[tech2 should] receive:@selector(isDependentOf:) andReturn:theValue(YES) withArguments:tech1];
		[[tech3 should] receive:@selector(isDependentOf:) andReturn:theValue(YES) withArguments:tech2];

		NSArray *dependencies1 = [techTree fetchTechDependencies:tech1];
		NSArray *dependencies2 = [techTree fetchTechDependencies:tech2];
		NSArray *dependencies3 = [techTree fetchTechDependencies:tech3];
		[[dependencies1 shouldNot] beNil];
		[[dependencies2 shouldNot] beNil];
		[[dependencies3 shouldNot] beNil];
		[[dependencies1 should] haveCountOf:1];
		[[theValue([dependencies1 containsObject:tech2]) should] beYes];
		[[theValue([dependencies1 containsObject:tech3]) should] beNo];
		[[theValue([dependencies2 containsObject:tech1]) should] beNo];
		[[theValue([dependencies2 containsObject:tech3]) should] beYes];
		[[theValue([dependencies3 containsObject:tech1]) should] beNo];
		[[theValue([dependencies3 containsObject:tech2]) should] beNo];
	});

	it(@"should fetch techs with different states", ^{
		AZRTechnology *tech1 = [techTree techNamed:techName1];
		AZRTechnology *tech2 = [techTree techNamed:techName2];
		AZRTechnology *tech3 = [techTree techNamed:techName3];

		[[tech1 should] receive:@selector(isUnavailable) andReturn:theValue(NO) withCountAtLeast:0];
		[[tech2 should] receive:@selector(isUnavailable) andReturn:theValue(YES) withCountAtLeast:0];
		[[tech3 should] receive:@selector(isUnavailable) andReturn:theValue(NO) withCountAtLeast:0];
		[[tech1 should] receive:@selector(isInProcess) andReturn:theValue(NO) withCountAtLeast:0];
		[[tech2 should] receive:@selector(isInProcess) andReturn:theValue(YES) withCountAtLeast:0];
		[[tech3 should] receive:@selector(isInProcess) andReturn:theValue(YES) withCountAtLeast:0];

		NSDictionary *states = [techTree fetchTechStates];
		[[states shouldNot] beNil];
		[[states should] haveCountOf:3];

		NSArray *normal = states[@(AZRTechnologyStateNormal)];
		NSArray *unavailable = states[@(AZRTechnologyStateUnavailable)];
		NSArray *inProcess = states[@(AZRTechnologyStateInProcess)];

		[[normal should] haveCountOf:1];
		[[unavailable should] haveCountOf:1];
		[[inProcess should] haveCountOf:2];

		[[theValue([normal containsObject:tech1]) should] beYes];
		[[theValue([normal containsObject:tech2]) should] beNo];
		[[theValue([normal containsObject:tech3]) should] beNo];

		[[theValue([unavailable containsObject:tech1]) should] beNo];
		[[theValue([unavailable containsObject:tech2]) should] beYes];
		[[theValue([unavailable containsObject:tech3]) should] beNo];

		[[theValue([inProcess containsObject:tech1]) should] beNo];
		[[theValue([inProcess containsObject:tech2]) should] beYes];
		[[theValue([inProcess containsObject:tech3]) should] beYes];

	});

	it(@"should process techs", ^{
		AZRTechnology *tech1 = [techTree techNamed:techName1];
		AZRTechnology *tech2 = [techTree techNamed:techName2];
		AZRTechnology *tech3 = [techTree techNamed:techName3];

		NSTimeInterval lastTick = [NSDate timeIntervalSinceReferenceDate];
		[[tech1 should] receive:@selector(process:) withArguments:theValue(lastTick)];
		[[tech2 should] receive:@selector(process:) withArguments:theValue(lastTick)];
		[[tech3 should] receive:@selector(process:) withArguments:theValue(lastTick)];

		[techTree process:lastTick];
	});
});

SPEC_END


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
		id tech1 = [AZRTechnology mock];
		[[tech1 should] receive:@selector(name) andReturn:techName1 withCountAtLeast:0];
		id tech2 = [AZRTechnology mock];
		[[tech2 should] receive:@selector(name) andReturn:techName2 withCountAtLeast:0];

		[techTree addTech:tech1];
		[techTree addTech:tech2];

		[[[techTree techNamed:tech1] should] equal:tech1];
		[[[techTree techNamed:tech2] should] equal:tech2];
		[[[techTree techNamed:tech1] shouldNot] equal:tech2];

		[[[techTree removeTech:techName1] should] equal:tech1];
		[[[techTree techNamed:techName1] should] beNil];

		[[techTree.technologies should] haveCountOf:1];
		[techTree addTech:tech1];
		[techTree addTech:tech1];
		[techTree addTech:tech2];
		[[techTree.technologies should] haveCountOf:2];
	});

	it(@"should fetch techs with different states", ^{
		AZRTechnology *tech1 = [techTree techNamed:techName1];
		AZRTechnology *tech2 = [techTree techNamed:techName2];
		AZRTechnology *tech3 = [AZRTechnology mock];
		[[tech3 should] receive:@selector(name) andReturn:techName3 withCountAtLeast:0];
		[techTree addTech:tech3];

		[[tech1 should] receive:@selector(isUnavailable) andReturn:theValue(NO) withCountAtLeast:0];
		[[tech2 should] receive:@selector(isUnavailable) andReturn:theValue(YES) withCountAtLeast:0];
		[[tech3 should] receive:@selector(isUnavailable) andReturn:theValue(NO) withCountAtLeast:0];
		[[tech1 should] receive:@selector(isInProcess) andReturn:theValue(NO) withCountAtLeast:0];
		[[tech2 should] receive:@selector(isInProcess) andReturn:theValue(YES) withCountAtLeast:0];
		[[tech3 should] receive:@selector(isInProcess) andReturn:theValue(YES) withCountAtLeast:0];

		NSDictionary *states = [techTree fetchTechStates];
		[[states should] haveCountOf:3];

		NSArray *normal = states[@(AZRTechnologyStateNormal)];
		NSArray *unavailable = states[@(AZRTechnologyStateUnavailable)];
		NSArray *inProcess = states[@(AZRTechnologyStateInProcess)];

		[[normal should] haveCountOf:1];
		[[unavailable should] haveCountOf:1];
		[[inProcess should] haveCountOf:2];

		[[theValue([normal containsObject:tech1]) should] beYes];
		[[theValue([normal containsObject:tech1]) should] beNo];
		[[theValue([normal containsObject:tech1]) should] beNo];

		[[theValue([unavailable containsObject:tech1]) should] beNo];
		[[theValue([unavailable containsObject:tech1]) should] beYes];
		[[theValue([unavailable containsObject:tech1]) should] beNo];

		[[theValue([inProcess containsObject:tech1]) should] beNo];
		[[theValue([inProcess containsObject:tech1]) should] beYes];
		[[theValue([inProcess containsObject:tech1]) should] beYes];

	});

	it(@"should process techs", ^{
		AZRTechnology *tech1 = [techTree techNamed:techName1];
		AZRTechnology *tech2 = [techTree techNamed:techName2];
		AZRTechnology *tech3 = [techTree techNamed:techName3];

		[[tech1 should] receive:@selector(calcAvailability)];
		[[tech2 should] receive:@selector(calcAvailability)];
		[[tech3 should] receive:@selector(calcAvailability)];

		NSTimeInterval lastTick = [NSDate timeIntervalSinceReferenceDate];
		// techs in "normal" (not inProcess) state should NOT be processed
		[[tech1 shouldNot] receive:@selector(process:) withArguments:theValue(lastTick)];
		// techs in "inProcess" (even if "unavailable") state SHOULD be processed
		[[tech2 should] receive:@selector(process:) withArguments:theValue(lastTick)];
		[[tech3 should] receive:@selector(process:) withArguments:theValue(lastTick)];

		[techTree process:lastTick];
	});
});

SPEC_END


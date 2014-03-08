//
//  AZRInGameResourceManagerSpec.m
//  Realmz
//  Spec for AZRInGameResourceManager
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRInGameResourceManager.h"
#import "AZRInGameResourceController.h"

SPEC_BEGIN(AZRInGameResourceManagerSpec)

describe(@"AZRInGameResourceManager", ^{
	NSString* resource1 = @"resource1";
	NSString* resource2 = @"resource2";
	NSString* resource3 = @"resource3";
	it(@"should properly instantiate", ^{
		AZRInGameResourceManager *manager = [AZRInGameResourceManager manager];
		[[manager shouldNot] beNil];
		[[manager should] beKindOfClass:[AZRInGameResourceManager class]];
	});
	it(@"should manage resources", ^{
		AZRInGameResourceManager *manager = [AZRInGameResourceManager manager];

		AZRInGameResource *res1 = [manager addResource:resource1];
		[[res1 shouldNot] beNil];
		[[res1.name shouldNot] beNil];
		[[res1.name should] equal:resource1];

		AZRInGameResourceController *controller = [AZRInGameResourceController mock];
		AZRInGameResource *res2 = [manager addResource:resource2 controlledBy:controller];
		[[res2 shouldNot] beNil];
		[[res2.name should] equal:resource2];
		[[res2.controller should] equal:controller];

		AZRInGameResource *res3 = [manager addResource:resource3];
		[[res3 shouldNot] beNil];
		[[res3.name should] equal:resource3];

		[[res1 shouldNot] equal:res2];
		[[res2.name shouldNot] equal:res3.name];

		AZRInGameResource *res = [manager resourceNamed:resource2];
		[[res shouldNot] beNil];
		[[res.name should] equal:resource2];

		AZRInGameResource *removed = [manager removeResource:resource1];
		[[removed shouldNot] beNil];
		[[removed should] beIdenticalTo:res1];
		[[[manager resourceNamed:resource1] should] beNil];
	});

	it(@"should handle resources in-outs", ^{
		AZRInGameResourceManager *manager = [AZRInGameResourceManager manager];

		AZRInGameResource *res1 = [manager addResource:resource1];
		[[theValue([res1 amount]) should] beZero];

		[manager resource:res1 addAmount:100];
		[[theValue([res1 amount]) should] equal:theValue(100)];


		AZRInGameResourceController *resourceController = [AZRInGameResourceController mock];
		AZRInGameResource *res2 = [manager addResource:resource2 controlledBy:resourceController];

		[[resourceController should] receive:@selector(resourceAmount:) andReturn:theValue(50) withCountAtLeast:1 arguments:res2];

		[[theValue([res2 amount]) should] equal:theValue(50)];

		[[resourceController should] receive:@selector(resource:setAmount:) andReturn:theValue(50) withArguments:res2, theValue(150)];
		[manager resource:res2 addAmount:100];

		[[resourceController should] receive:@selector(resourceAmount:) andReturn:theValue(150) withArguments:res2];
		[[theValue([res2 amount]) should] equal:theValue(150)];
	});

	it(@"should enumerate resources", ^{
		AZRInGameResourceManager *manager = [AZRInGameResourceManager manager];

		[manager addResource:resource1];
		[manager addResource:resource3];

		{
		NSArray *resources = [manager registeredResources];
		[[resources shouldNot] beNil];
		[[resources should] haveCountOf:2];
		[[theValue([resources containsObject:resource1]) should] beYes];
		[[theValue([resources containsObject:resource2]) should] beNo];
		[[theValue([resources containsObject:resource3]) should] beYes];
		}

		[manager addResource:resource2];

		{
		NSArray *resources = [manager registeredResources];
		[[resources shouldNot] beNil];
		[[resources should] haveCountOf:3];
		[[theValue([resources containsObject:resource1]) should] beYes];
		[[theValue([resources containsObject:resource2]) should] beYes];
		[[theValue([resources containsObject:resource3]) should] beYes];
		}
});
});

SPEC_END

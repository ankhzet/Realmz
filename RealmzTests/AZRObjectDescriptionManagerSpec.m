//
//  AZRObjectDescriptionManagerSpec.m
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRObjectClassDescriptionManager.h"
#import "AZRObjectClassDescription.h"
#import "AZRActorClassDescription.h"

SPEC_BEGIN(AZRObjectDescriptionManagerSpec)

describe(@"Testing descriptions manager", ^{
	
	__block AZRObjectClassDescriptionManager *manager = [AZRObjectClassDescriptionManager getInstance];
	__block AZRObjectClassDescription *description1;
	
	
	it(@"should be a singletone", ^{
		[[manager shouldNot] beNil];
		[[manager should] beKindOfClass:[AZRObjectClassDescriptionManager class]];
		
		[[[AZRObjectClassDescriptionManager getInstance] should] equal:manager];
	});
	
	it(@"should load descriptions on request", ^{
		description1 = [manager getDescription:@"actor"];
		[[description1 shouldNot] beNil];
		[[description1.name should] equal:@"actor"];
		[[description1 should] beKindOfClass:[AZRActorClassDescription class]];

		description1 = [manager getDescription:@"visible"];
		[[description1 shouldNot] beNil];
		[[description1.name should] equal:@"visible"];
		[[description1 should] beKindOfClass:[AZRObjectClassDescription class]];
	});
	
	it(@"should not reinstantiate same descriptions", ^{
		AZRObjectClassDescription *description2 = [manager getDescription:@"visible"];
		[[description2 shouldNot] beNil];
		[[description1 should] beIdenticalTo:description2];
	});
});

SPEC_END

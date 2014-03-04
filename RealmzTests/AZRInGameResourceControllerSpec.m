//
//  AZRInGameResourceControllerSpec.m
//  Realmz
//  Spec for AZRInGameResourceController
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRInGameResourceController.h"
#import "AZRInGameResource.h"

SPEC_BEGIN(AZRInGameResourceControllerSpec)

describe(@"AZRInGameResourceController", ^{
	it(@"should properly initialize", ^{
		AZRInGameResourceController *controller = [AZRInGameResourceController controller];
		[[controller shouldNot] beNil];
		[[controller should] beKindOfClass:[AZRInGameResourceController class]];
	});
	it(@"should manage plain resources", ^{
		AZRInGameResourceController *controller = [AZRInGameResourceController controller];

		AZRInGameResource *resource = [AZRInGameResource resourceWithName:@"res1"];

		[[theValue([controller resourceAmount:resource]) should] equal:theValue(0)];
		[controller resource:resource setAmount:100];
		[[theValue([controller resourceAmount:resource]) should] equal:theValue(100)];
		[controller resource:resource setAmount:50];
		[[theValue([controller resourceAmount:resource]) should] equal:theValue(50)];
		[controller resource:resource setAmount:-1];
		[[theValue([controller resourceAmount:resource]) should] equal:theValue(0)];
	});
});

SPEC_END

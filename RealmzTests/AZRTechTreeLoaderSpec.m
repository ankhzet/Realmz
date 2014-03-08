//
//  AZRTechLoaderSpec.m
//  Realmz
//  Spec for AZRTechLoader
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRTechLoader.h"
#import "AZRTechTree.h"
#import "AZRTechnology.h"

SPEC_BEGIN(AZRTechTreeLoaderSpec)

describe(@"AZRTechLoader", ^{
	it(@"should properly initialize", ^{
		AZRTechLoader *loader = [AZRTechLoader new];
		[[loader shouldNot] beNil];
		[[[loader resourceType] should] equal:AZRUnifiedFileTypeTechnology];
		[[[loader grammar] should] equal:@"tech"];
	});

	it(@"should load techs", ^{
		AZRTechLoader *loader = [AZRTechLoader new];

		NSString *techTestSource = @"\
		tech 'test' {\
		author 'Ankh';\
		version '1.0';\
		description 'Some description';\
		multiple 12;\
		implement-for 65;\
		final;\
		}\
		";
		AZRTechnology *tech = [loader loadFromString:techTestSource];
		[[tech shouldNot] beNil];
		[[tech should] beKindOfClass:[AZRTechnology class]];
		[[[tech name] should] equal:@"test"];
		[[[tech author] should] equal:@"Ankh"];
		[[[tech version] should] equal:@"1.0"];
		[[[tech summary] should] equal:@"Some description"];
		[[theValue(tech.multiple) should] equal:theValue(12)];
		[[theValue(tech.iterationTime) should] equal:theValue(65)];
		[[theValue(tech.final) should] beYes];
	});

	it(@"should load techs", ^{
		AZRTechLoader *loader = [AZRTechLoader new];

		NSString *techTestSource = @"\
		tech 'test' {\
		drains {\
		resource 'res1';\
		resource 'res2': 100;\
		targeted tech 'tech1';\
		unit 'unit1': 10;\
		}\
		gains {\
		resource 'res1';\
		tech 'tech1';\
		tech 'tech2';\
		unit 'unit1';\
		replace unit 'unit1';\
		unit 'unit1': 100;\
		}\
		}\
		";
		AZRTechnology *tech = [loader loadFromString:techTestSource];
		[[tech shouldNot] beNil];

		{
			NSArray *resources = [tech getDrained:AZRTechResourceTypeResource];
			[[resources shouldNot] beNil];
			[[resources should] haveCountOf:2];

			NSArray *units = [tech getDrained:AZRTechResourceTypeUnit];
			[[units shouldNot] beNil];
			[[units should] haveCountOf:1];
			AZRTechResource *r1 = [units firstObject];
			[[r1.resource should] equal:@"unit1"];

			NSArray *techs = [tech getDrained:AZRTechResourceTypeTech];
			[[techs shouldNot] beNil];
			[[techs should] haveCountOf:1];
			AZRTechResource *r2 = [techs firstObject];
			[[r2.resource should] equal:@"tech1"];
			[[theValue(r2.handler) should] equal:theValue(AZRResourceHandlerTargeted)];
		}

		{
			NSArray *resources = [tech getGained:AZRTechResourceTypeResource];
			[[resources shouldNot] beNil];
			[[resources should] haveCountOf:1];
			AZRTechResource *r1 = [resources firstObject];
			[[r1.resource should] equal:@"res1"];

			NSArray *units = [tech getGained:AZRTechResourceTypeUnit];
			[[units shouldNot] beNil];
			[[units should] haveCountOf:3];

			NSArray *techs = [tech getGained:AZRTechResourceTypeTech];
			[[techs shouldNot] beNil];
			[[techs should] haveCountOf:2];
		}
	});
});

SPEC_END

//
//  AZRDescriptionBuilderSpec.m
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRClassDescriptionLoader.h"
#import "AZRObjectClassDescription.h"

SPEC_BEGIN(AZRDescriptionBuilderSpec)

describe(@"Testing description builder", ^{
	AZRClassDescriptionLoader *builder = [AZRClassDescriptionLoader new];
	
	NSString *desc1 = @"\
	object \"obj1\"(\"visible_object\") {\
	}\
	}";
	
	NSString *desc2 = @"\
	object \"obj1\" (\"visible\") {\
	description \"object 1\";\
	author \"Ankh\";\
	properties {\
	string \"some string\";\
	number 0.65;\
	}\
	discoverable actions {\
	action \"some action\";\
	}\
	discoverable properties {\
	vector1 [0, 1, 2];\
	vector2 [\"string1\", 1, \"string2\", [1, 0, \"string3\"]];\
	}\
	actions {\
	}\
	}";

	it(@"should fail parsing of broken object descriptions", ^{
		AZRObjectClassDescription *d = [builder loadFromString:desc1];
		[[d should] beNil];
	});
	
	AZRObjectClassDescription *d = [builder loadFromString:desc2];
	it(@"should parse object descriptions", ^{
		[[d shouldNot] beNil];
		[[d.name should] equal:@"obj1"];
		[[d.summary should] equal:@"object 1"];
		[[@([d.publicProperties count]) should] equal:@(2)];
		
		[[[d hasProperty:@"number"] shouldNot] beNil];
		[[[d hasProperty:@"action"] shouldNot] beNil];
		[[[d hasProperty:@"vector1"] shouldNot] beNil];
		[[[d hasPublicProperty:@"number"] shouldNot] beNil];
		[[[d hasPublicProperty:@"action"] should] beNil];
	});
	it(@"should parse parent descriptions", ^{
		[[d.parent shouldNot] beNil];
		[[d.parent.name should] equal:@"visible"];
	});
});

SPEC_END


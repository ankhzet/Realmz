//
//  AZRObjectDescriptionSpec.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRObjectClassDescription.h"
#import "AZRObjectProperty.h"

#define BOOL_STATE(bool, state) \
	[[theValue(bool) should] state]

SPEC_BEGIN(AZRObjectDescriptionSpec)

describe(@"Testing AZRObjectDescription", ^{
	
	__block AZRObjectClassDescription *objectDescription;
	__block BOOL boolState;
	
	it(@"should load description from DB", ^{
		static NSString *objectDescriptor = @"object";
		objectDescription = [[AZRObjectClassDescription alloc] initWithName:objectDescriptor];
		
		[[objectDescription shouldNot] beNil];
		[[objectDescription.name should] equal:objectDescriptor];
	});
	
	it(@"should manage properties", ^{
		static NSString *property1 = @"object_render_color";
		static NSString *property2 = @"object_inspect_inspected";
		
		boolState = [objectDescription addProperty:property1 withType: AZRPropertyTypePublic];
		[[theValue(boolState) should] beYes];
		
		boolState = [objectDescription addProperty:property2 withType: AZRPropertyTypeDiscoverable];
		[[theValue(boolState) should] beYes];
		
		[[[objectDescription hasProperty:property1] shouldNot] beNil];
		[[[objectDescription hasProperty:property2] shouldNot] beNil];
		[[[objectDescription hasPublicProperty:property1] shouldNot] beNil];
		[[[objectDescription hasPublicProperty:property2] should] beNil];
	});
	
	it(@"should provide object info", ^{
		
	});
	
});

SPEC_END

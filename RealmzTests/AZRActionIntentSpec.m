//
//  AZRActionIntentSpec.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRActionIntent.h"
#import "AZRObject.h"
#import "AZRActor.h"
#import "AZRObjectClassDescription.h"
#import "AZRActorClassDescription.h"

#define PREPARE_ACTION(_initiator, _target, _action) \
static NSString *initiatorDescriptor = _initiator; \
static NSString *targetDescriptor = _target; \
static NSString *actionName = _action; \
AZRActor *initiator = (AZRActor *)[[[AZRActorClassDescription alloc] initWithName:initiatorDescriptor] instantiateObject]; \
[[initiator shouldNot] beNil]; \
AZRObject *target = [[[AZRObjectClassDescription alloc] initWithName:targetDescriptor] instantiateObject]; \
[[target shouldNot] beNil]; \
[target.classDescription addProperty:_action withType:AZRPropertyTypePublic | AZRPropertyTypeAction]; \
AZRActionIntent *intent = [AZRActionIntent new];\
[intent setInitiator:initiator];\
[intent setTarget:target];\
[intent setAction:actionName];\


SPEC_BEGIN(AZRActionIntentSpec)

describe(@"Testing AZRActionIntent", ^{
	it(@"should be properly initialized and executed", ^{
		PREPARE_ACTION(@"actor", @"object", @"inspect");

		BOOL executed = [intent execute];
		[[theValue(executed) should] beYes];
	});
	
	
});

SPEC_END

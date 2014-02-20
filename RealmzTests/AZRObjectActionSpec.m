//
//  AZRObjectActionSpec.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//


#import "Kiwi.h"

#import "AZRActionManager.h"
#import "AZRObjectAction.h"
#import "AZRActionIntent.h"

#import "AZRObjectClassDescription.h"
#import "AZRActorClassDescription.h"
#import "AZRObject.h"

SPEC_BEGIN(AZRObjectActionSpec)

describe(@"AZRObjectAction", ^{
	__block AZRObjectAction *action;
	static NSString *actionName = @"inspect";
	
	it(@"should be properly loaded", ^{
		action = [AZRActionManager getAction:actionName];
		
		[[action shouldNot] beNil];
		[[action.name should] equal:actionName];
		
	});
	
	it(@"should not reinstantiate actions", ^{
		[[action should] equal:[AZRActionManager getAction:actionName]];
	});
	
	it(@"should be properly executed", ^{
		static NSString *initiatorDescriptor = @"spectator";
		static NSString *targetDescriptor = @"object";
		
		AZRActor *initiator = (AZRActor *)[[[AZRActorClassDescription alloc] initWithName:initiatorDescriptor] instantiateObject];
		
		AZRObject *target = [[[AZRObjectClassDescription alloc] initWithName:targetDescriptor] instantiateObject];
		
		BOOL executed = [action executeOn:target withInitiator:initiator];
		
		[[theValue(executed) should] beYes];
	});
	
});

SPEC_END

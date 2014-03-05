//
//  AZRPlayerSpec.m
//  Realmz
//  Spec for AZRPlayer
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRPlayer.h"
#import "AZRGame.h"
#import "AZRPlayerState.h"

SPEC_BEGIN(AZRPlayerSpec)

describe(@"AZRPlayer", ^{
	it(@"should properly initialize", ^{
		AZRPlayer *player = [AZRPlayer playerForGame:nil];
		[[player shouldNot] beNil];
		[[player should] beKindOfClass:[AZRPlayer class]];
	});

	it(@"should initialize state for self", ^{
		AZRPlayer *player = [AZRPlayer playerForGame:nil];
		AZRPlayerState *state = player.state;
		[[state shouldNot] beNil];

		[[state.player should] equal:player];
	});
	
});

SPEC_END

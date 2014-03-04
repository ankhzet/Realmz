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
	});

	it(@"should manage player states dependent on players", ^{
		AZRGame *game = [AZRGame game];
		AZRPlayer *player1 = [game newPlayer];
		AZRPlayer *player2 = [game newPlayer];
		AZRPlayer *player3 = [game newPlayer];

		AZRPlayerState *state1 = player1.state;
		AZRPlayerState *state2 = player2.state;
		AZRPlayerState *state3 = player3.state;

		[[state1.player should] equal:player1];
		[[state2.player should] equal:player2];
		[[state3.player should] equal:player3];
	});
	
});

SPEC_END

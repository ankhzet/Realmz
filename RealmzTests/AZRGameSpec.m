//
//  AZRGameSpec.m
//  Realmz
//  Spec for AZRGame
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRGame.h"
#import "AZRPlayer.h"
#import "AZRPlayerState.h"
#import "AZRRealm.h"
#import "AZRMap.h"

SPEC_BEGIN(AZRGameSpec)

describe(@"AZRGame", ^{
	it(@"should properly initialize", ^{
		AZRGame *game = [AZRGame game];
		[[game shouldNot] beNil];
		[[game should] beKindOfClass:[AZRGame class]];
	});

	it(@"should manage players", ^{
		AZRGame *game = [AZRGame game];

		AZRPlayer *player1 = [game newPlayer];
		[[player1 shouldNot] beNil];
		[[player1 should] beKindOfClass:[AZRPlayer class]];

		AZRPlayer *player2 = [game newPlayer];
		[[player2 shouldNot] beNil];
		[[player2 should] beKindOfClass:[AZRPlayer class]];

		AZRPlayer *player3 = [game newPlayer];
		[[player3 shouldNot] beNil];
		[[player3 should] beKindOfClass:[AZRPlayer class]];

		[[player1 shouldNot] beIdenticalTo:player2];
		[[player2 shouldNot] beIdenticalTo:player3];
		[[theValue(player1.uid) should] equal:theValue(1)];
		[[theValue(player2.uid) should] equal:theValue(2)];
		[[theValue(player3.uid) should] equal:theValue(3)];
	});

	it(@"should manage player states dependent on players", ^{
		AZRGame *game = [AZRGame game];
		AZRPlayer *player1 = [game newPlayer];
		AZRPlayer *player2 = [game newPlayer];
		AZRPlayer *player3 = [game newPlayer];

		AZRPlayerState *state1 = [game playerState:player1];
		AZRPlayerState *state2 = [game playerState:player2];
		AZRPlayerState *state3 = [game playerState:player3];
		[[state1.player should] equal:player1];
		[[state2.player should] equal:player2];
		[[state3.player should] equal:player3];
	});

	it(@"should manage game realm", ^{
		AZRGame *game = [AZRGame game];
		AZRRealm *realm = [game realm];
		[[realm shouldNot] beNil];
	});

	it(@"should manage game map", ^{
		AZRGame *game = [AZRGame game];
		AZRMap *map = [game map];
		[[map should] beNil];

		map = [game loadMapNamed:@"map01"];
		[[map shouldNot] beNil];
		[[map should] equal:[game map]];
	});
});

SPEC_END

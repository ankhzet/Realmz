//
//  AZRPlayerStateSpec.m
//  Realmz
//  Spec for AZRPlayerState
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRPlayerState.h"
#import "AZRInGameResourceManager.h"
#import "AZRTechTree.h"
#import "AZRPlayer.h"
#import "AZRGame.h"

SPEC_BEGIN(AZRPlayerStateSpec)

describe(@"AZRPlayerState", ^{
	it(@"should properly initialize", ^{
		AZRPlayerState *state = [AZRPlayerState stateForPlayer:nil];
		[[state shouldNot] beNil];
		[[state should] beKindOfClass:[AZRPlayerState class]];

		AZRPlayerState *state2 = [AZRPlayerState stateForPlayer:nil];

		[[state shouldNot] equal:state2];
	});

	it(@"should provide unique resources manager and tech manager for each player", ^{
		AZRPlayer *player1 = [AZRPlayer mock];
		AZRPlayer *player2 = [AZRPlayer mock];
		AZRGame *game1 = [AZRGame mock];
		AZRGame *game2 = [AZRGame mock];
		AZRInGameResourceManager *rManager1 = [NSObject mock];
		AZRInGameResourceManager *rManager2 = [NSObject mock];
		AZRTechTree *tManager1 = [NSObject nullMock];
		AZRTechTree *tManager2 = [NSObject nullMock];
		[[player1 should] receive:@selector(game) andReturn:game1 withCountAtLeast:2];
		[[player2 should] receive:@selector(game) andReturn:game2 withCountAtLeast:2];
		[[game1 should] receive:@selector(newResourcesManager) andReturn:rManager1 withCountAtLeast:1];
		[[game2 should] receive:@selector(newResourcesManager) andReturn:rManager2 withCountAtLeast:1];
		[[game1 should] receive:@selector(newTechTree) andReturn:tManager1 withCountAtLeast:1];
		[[game2 should] receive:@selector(newTechTree) andReturn:tManager2 withCountAtLeast:1];

		AZRPlayerState *state1 = [AZRPlayerState stateForPlayer:player1];
		AZRPlayerState *state2 = [AZRPlayerState stateForPlayer:player2];


		[[state1.resourcesManager shouldNot] beNil];
		[[state2.resourcesManager shouldNot] beNil];
		[[state1.resourcesManager shouldNot] equal:state2.resourcesManager];

		[[state1.techTree shouldNot] beNil];
		[[state2.techTree shouldNot] beNil];
		[[state1.techTree shouldNot] equal:state2.techTree];
	});
});

SPEC_END

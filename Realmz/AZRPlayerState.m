//
//  AZRPlayerState.m
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRPlayerState.h"
#import "AZRPlayer.h"
#import "AZRInGameResourceManager.h"
#import "AZRTechTree.h"
#import "AZRGame.h"

@implementation AZRPlayerState

#pragma mark - Instantiation

+ (instancetype) stateForPlayer:(AZRPlayer *)player {
	return [[self alloc] initForPlayer:player];
}

- (id)initForPlayer:(AZRPlayer *)player {
	if (!(self = [super init]))
		return self;

	_player = player;
	_resourcesManager = [player.game newResourcesManager];
	_techTree = [player.game newTechTree];
	[_techTree setResourceManager:_resourcesManager];
	return self;
}

#pragma mark - Implementation

- (void) process:(NSTimeInterval)currentTime {
	[_techTree process:currentTime];
}


@end

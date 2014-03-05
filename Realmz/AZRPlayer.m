//
//  AZRPlayer.m
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRPlayer.h"
#import "AZRPlayerState.h"

@implementation AZRPlayer

+ (instancetype) playerForGame:(AZRGame *)game {
	return [[self alloc] initForGame:game];
}

- (id)initForGame:(AZRGame *)game {
	if (!(self = [super init]))
		return self;

	_game = game;
	_state = [AZRPlayerState stateForPlayer:self];
	return self;
}

@end

//
//  AZRGame.m
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGame.h"
#import "AZRPlayer.h"
#import "AZRPlayerState.h"
#import "AZRRealm.h"
#import "AZRMap.h"
#import "AZRMapLoader.h"

@interface AZRGame () {
	NSMutableDictionary *players;
}

@end
@implementation AZRGame
@synthesize realm = _realm, map = _map;

#pragma mark - Instantiation

+ (instancetype) game {
	return [[self alloc] init];
}

+ (instancetype) new {
	return [self game];
}

- (id)init {
	if (!(self = [super init]))
		return self;

	players = [NSMutableDictionary dictionary];
	return self;
}

#pragma mark - Players

- (AZRPlayer *) newPlayer {
	AZRPlayer *player = [AZRPlayer new];
	player.game = self;
	player.uid = [players count] + 1;
	players[@(player.uid)] = player;
	return player;
}

- (AZRPlayer *) getPlayerByUID:(int)uid {
	return players[@(uid)];
}

#pragma mark - Realm

- (AZRRealm *) realm {
	if (!_realm) {
		_realm = [AZRRealm realm];
	}
	return _realm;
}

#pragma mark - Map

- (AZRMap *) loadMapNamed:(NSString *)mapName {
	AZRMapLoader *mapLoader = [AZRMapLoader new];
	_map = [mapLoader loadFromFile:mapName];
	return _map;
}

@end

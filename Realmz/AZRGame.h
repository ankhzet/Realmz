//
//  AZRGame.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRPlayer, AZRRealm, AZRMap;
@interface AZRGame : NSObject

/*!@brief Returns game realm controller.*/
@property (nonatomic, readonly) AZRRealm *realm;
@property (nonatomic, readonly) AZRMap *map;

/*!@brief Creates new game instance.*/
+ (instancetype) game;

/*!@brief Add new player to the game.*/
- (AZRPlayer *) newPlayer;
/*!@brief Returns player with specified UID.*/
- (AZRPlayer *) getPlayerByUID:(int)uid;

/*!@brief Loads map for game realm.*/
- (AZRMap *) loadMapNamed:(NSString *)mapName;

@end

//
//  AZRGame.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRPlayer, AZRRealm, AZRMap;
@class AZRInGameResourceManager, AZRTechTree;
@interface AZRGame : NSObject

/*!@brief Returns game realm controller.*/
@property (nonatomic, readonly) AZRRealm *realm;
@property (nonatomic, readonly) AZRMap *map;

@property (nonatomic, readonly) NSString *techRoot;

/*!@brief Creates new game instance.*/
+ (instancetype) game;

/*!@brief Add new player to the game.*/
- (AZRPlayer *) newPlayer;
/*!@brief Returns player with specified UID.*/
- (AZRPlayer *) getPlayerByUID:(int)uid;
/*!@brief Returns player state for human player.*/
- (AZRPlayer *) getHumanPlayer;

/*!@brief Instantiates new resources manager, which can be used by players etc.*/
- (AZRInGameResourceManager *) newResourcesManager;
/*!@brief Instantiates new tech manager, which can be used by players etc.*/
- (AZRTechTree *) newTechTree;


/*!@brief Loads map for game realm.*/
- (AZRMap *) loadMapNamed:(NSString *)mapName;

/*!@brief Process realm, players and map logic.*/
- (void) process:(NSTimeInterval)currentTime;

@end

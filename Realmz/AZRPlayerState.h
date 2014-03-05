//
//  AZRPlayerState.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRPlayer, AZRInGameResourceManager, AZRTechTree;
@interface AZRPlayerState : NSObject

@property (nonatomic, weak, readonly) AZRPlayer *player;
@property (nonatomic, readonly) AZRInGameResourceManager *resourcesManager;
@property (nonatomic, readonly) AZRTechTree *techTree;

+ (instancetype) stateForPlayer:(AZRPlayer *)player;

@end

//
//  AZRPlayer.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HUMAN_PLAYER 1

@class AZRPlayerState, AZRGame;
@interface AZRPlayer : NSObject

@property (nonatomic, weak, readonly) AZRGame *game;
@property (nonatomic) int uid;
@property (nonatomic, readonly) AZRPlayerState *state;

+ (instancetype) playerForGame:(AZRGame *)game;
- (void) process:(NSTimeInterval)currentTime;

@end

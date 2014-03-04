//
//  AZRPlayer.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRPlayerState;
@interface AZRPlayer : NSObject

@property (nonatomic) int uid;
@property (nonatomic) AZRPlayerState *state;

@end

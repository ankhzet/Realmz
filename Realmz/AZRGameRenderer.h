//
//  AZRRealmRenderer.h
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class AZRGame;
@interface AZRGameRenderer : SKNode

@property (nonatomic, weak, readonly) AZRGame *game;
@property (nonatomic, readonly) SKNode *mapRootNode;
@property (nonatomic, readonly) SKNode *realmRootNode;

/*!@brief Returns new instance of renderer for provided game instance.*/
+ (instancetype) rendererForGame:(AZRGame *)game;

/*!
 @brief Returns map chunk under specified coordinates.
 @param pointXY Coordinates, occupied by map chunk, in map units (not cells).
 */
- (NSArray *) chunkAt:(CGPoint)pointXY;

/*!@brief Builds map layers and chunks for rendering.*/
- (void) buildForRendering:(CGSize)tileSize;


- (void) processed:(CFTimeInterval)currentTime;

@end

//
//  AZRMapLayerRenderer.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class AZRMapLayer;
@interface AZRMapLayerRenderer : SKNode

@property (nonatomic, weak, readonly) AZRMapLayer *layer;
@property (nonatomic) BOOL showTileShape;

/*!@brief Returns new renderer instance for provided layer.*/
+ (instancetype) rendererForMapLayer:(AZRMapLayer *)layer;

/*!@brief Builds node tree for layer rendering.*/
- (BOOL) buildForTileSize:(CGSize)tileSize;

@end

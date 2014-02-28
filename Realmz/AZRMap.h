//
//  AZRMap.h
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRMapCommons.h"
#import "AZRUnifiedResource.h"
#import "AZRRealm.h"
#import <SpriteKit/SpriteKit.h>

@class AZRMapLayer;

@interface AZRMap : AZRUnifiedResource
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *summary;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *version;

@property (nonatomic)int width;
@property (nonatomic)int height;

@property (nonatomic, weak) AZRRealm *realm;
@property (nonatomic) NSArray *globalScripts;
@property (nonatomic)NSMutableDictionary *layers;

@property (nonatomic) SKNode *graphicsNode;

/*!
 @brief Returns coordinates (in cells) of map center.
 */
- (AZRIntPoint) centerCell;

/*!
 @brief Returns map chunk under specified coordinates.
 @param pointXY Coordinates, occupied by map chunk, in map units (not cells).
 */
- (NSArray *) chunkAt:(CGPoint)pointXY;

/*!
 @brief Adding new layer with specified name, if not exists.
 @param layerIdentifier Identifier for layer to search for.
 @return Returns newly created or alredy existed layer.
 */
- (AZRMapLayer *) addNewLayerNamed:(NSString *)layerIdentifier;

/*!
 @brief Adding provided layer to map. 
 @brief If map has layer with same name - it will be replaced.
 @param layer Layer, that will be added to map
 @return Returns added layer.
 */
- (AZRMapLayer *) addLayer:(AZRMapLayer *)layer;

/*!
 @brief Builds map layers and chunks for rendering.
 */
- (void) buildForRendering:(CGSize)tileSize;

@end

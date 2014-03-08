//
//  AZRMapChunk.m
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMapChunk.h"
#import "AZRMap.h"
#import "AZRMapLayer.h"
#import "AZRMapLayerCellShortcut.h"
#import "AZRObject.h"
#import "AZRGame.h"
#import "AZRRealm.h"

@implementation AZRMapChunk

+ (instancetype) chunkForGame:(AZRGame *)game withSize:(int)size andOffset:(AZRIntPoint)offset {
	AZRMapChunk *chunk = [self node];
	chunk->game = game;
	chunk->size = size;
	chunk->mapX = offset.x;
	chunk->mapY = offset.y;
	AZRIntPoint mapCenter = [[game map] centerCell];
	chunk->offsetX = mapCenter.x + offset.x * size;
	chunk->offsetX = mapCenter.y + offset.y * size;
	return chunk;
}

- (void) buildForTileSize:(CGSize)tile {
	[self removeAllChildren];

	AZRRealm *realm = [game realm];
	AZRMap *map = [game map];
	for (NSString *layerID in [map.layers allKeys]) {
		AZRMapLayer *layer = map.layers[layerID];
		if (layer.tiled) continue;

		int halfW = layer.width / 2;
		int halfH = layer.height / 2;

		for (int y = - halfH; y < halfH; y++) {
			for (int x = - halfW; x < halfW; x++) {
				int cell = [layer gridCellAtXY:AZRIntPointMake(x, y)];
				if (!cell)
					continue;

				AZRMapLayerCellShortcut *shortcut = layer.shortcuts[@(cell)];
				AZRObject *object = [realm spawnObject:shortcut.identifier atX:x andY:y];
				if (!object) {
					[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Failed to instantiate [%@]", shortcut.identifier];
					continue;
				}
//				NSLog(@"spawning %@", shortcut.identifier);
			}
		}
		
	}
}

@end

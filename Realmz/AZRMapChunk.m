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

@implementation AZRMapChunk

- (void) initForMap:(AZRMap *)map withChunkSize:(int)chunkSize andOffset:(AZRIntPoint)offset {
	mapX = offset.x;
	mapY = offset.y;
	size = chunkSize;
	parentMap = map;
	AZRIntPoint mapCenter = [map centerCell];
	offsetX = mapCenter.x + mapX * size;
	offsetX = mapCenter.y + mapY * size;
}

- (void) buildSceneTreeForTileSize:(CGSize)tile {
	[self removeAllChildren];

	for (NSString *layerID in [parentMap.layers allKeys]) {
		AZRMapLayer *layer = parentMap.layers[layerID];
		if (layer.tiled) continue;

		int halfW = layer.width / 2;
		int halfH = layer.height / 2;

		for (int y = - halfH; y < halfH; y++) {
			for (int x = - halfW; x < halfW; x++) {
				int cell = [layer gridCellAtXY:AZRIntPointMake(x, y)];
				if (!cell)
					continue;

				AZRMapLayerCellShortcut *shortcut = layer.shortcuts[@(cell)];
				AZRObject *object = [parentMap.realm spawnObject:shortcut.identifier atX:x andY:y];
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

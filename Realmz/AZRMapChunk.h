//
//  AZRMapChunk.h
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "AZRMapCommons.h"

@class AZRMap;
@interface AZRMapChunk : SKNode  {
	@public
	int mapX;
	int mapY;
	int offsetX;
	int offsetY;
	int size;
	AZRMapChunk *dx[2];
	AZRMapChunk *dy[2];
	__weak AZRMap *parentMap;
}

- (void) initForMap:(AZRMap *)map withChunkSize:(int)size andOffset:(AZRIntPoint)offset;
- (void) buildSceneTreeForTileSize:(CGSize)tile;

@end


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

@class AZRGame;
@interface AZRMapChunk : SKNode  {
	@public
	int mapX;
	int mapY;
	int offsetX;
	int offsetY;
	int size;
	AZRMapChunk *dx[2];
	AZRMapChunk *dy[2];
	__weak AZRGame *game;
}

+ (instancetype) chunkForGame:(AZRGame *)game withSize:(int)size andOffset:(AZRIntPoint)offset;

- (void) buildForTileSize:(CGSize)tile;

@end


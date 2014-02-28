//
//  AZRMap.m
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMap.h"
#import "AZRMapCommons.h"
#import "AZRMapLayer.h"
#import "AZRMapChunk.h"

@interface AZRMap ()
@property int chunkSize;
@property NSMutableArray *chunks;
@end

@implementation AZRMap
@synthesize width = _width;
@synthesize height = _height;
@synthesize layers = _layers;
@synthesize chunks = _chunks;
@synthesize chunkSize = _chunkSize;
@synthesize graphicsNode = _graphicsNode;

- (id)init {
	if (!(self = [super init]))
		return self;

	_layers = [NSMutableDictionary dictionary];
	_chunks = [NSMutableArray array];
	_graphicsNode = [SKNode node];
	return self;
}

- (void) buildForRendering:(CGSize)tileSize {
	int z = 0;
	for (AZRMapLayer *layer in [self.layers allValues]) {
    [layer buildForTileSize:tileSize];
		layer.zPosition = z++;
		_width = MAX(_width, layer.width);
		_height = MAX(_height, layer.height);
		[self.graphicsNode addChild:layer];
	}

	AZRMapChunk *chunk = [AZRMapChunk new];
	[chunk initForMap:self withChunkSize:20 andOffset:AZRIntPointMake(0, 0)];
	[self.chunks addObject:chunk];

	for (AZRMapChunk *chunk in self.chunks) {
		[chunk buildSceneTreeForTileSize:tileSize];
		chunk.position = CGPointMake(- tileSize.width * chunk->offsetX, - tileSize.height * chunk->offsetY);
    [self.graphicsNode addChild:chunk];
	}
}

- (AZRMapLayer *) addNewLayerNamed:(NSString *)layerIdentifier {
	AZRMapLayer *layer = _layers[layerIdentifier];
	if (!layer) {
		layer = [AZRMapLayer new];
		[layer setName:layerIdentifier];
		return [self addLayer:layer];
	}
	return layer;
}

- (AZRMapLayer *) addLayer:(AZRMapLayer *)layer {
	_layers[layer.name] = layer;
	return layer;
}

- (AZRIntPoint) cellToChunk:(AZRIntPoint)cellXY {
	cellXY.x = truncf(cellXY.x / _chunkSize);
	cellXY.y = truncf(cellXY.y / _chunkSize);
	return cellXY;
}

- (NSArray *) chunkAt:(CGPoint)pointXY {
	AZRIntPoint chunkXY = [self cellToChunk:AZRIntPointMake(pointXY.x, pointXY.y)];
	chunkXY.x = CONSTRAINT(chunkXY.x, 0, _width);
	chunkXY.y = CONSTRAINT(chunkXY.y, 0, _height);
	return _chunks[chunkXY.y][chunkXY.x];
}

- (AZRIntPoint) centerCell {
	return AZRIntPointMake(_width / 2, _height / 2);
}

@end

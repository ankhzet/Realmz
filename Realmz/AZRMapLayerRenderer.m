//
//  AZRMapLayerRenderer.m
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMapLayerRenderer.h"
#import "AZRMapLayer.h"
#import "AZRSpriteHelper.h"
#import "AZRMapLayerCellShortcut.h"

@interface AZRMapLayerRenderer () {
	NSMutableDictionary *texturesCache;
}
@end
@implementation AZRMapLayerRenderer

static NSString *tilesetAtlas = @"tileset";

+ (instancetype) rendererForMapLayer:(AZRMapLayer *)layer {
	AZRMapLayerRenderer *instance = [self node];
	instance->_layer = layer;
	instance.name = layer.name;
	return instance;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	texturesCache = [NSMutableDictionary dictionary];
	return self;
}

- (BOOL) buildForTileSize:(CGSize)tileSize {
	int w = _layer.width;
	int h = _layer.height;
	if (_layer.tiled) {
		int halfW = w / 2;
		int halfH = h / 2;
		for (int ty = -halfH; ty < halfH; ty++) {
			float dy = ty * tileSize.height;
			for (int tx = halfW - 1; tx >= -halfW; tx--) {
				int cell = [_layer gridCellAtXY:AZRIntPointMake(tx, ty)];
				if (!cell) continue;

				float dx = tx * tileSize.width;
				SKNode *tile = [self decodeTile:cell];
				tile.position = cartXYtoIsoXY(CGPointMake(dx, dy));
				[self addChild:tile];
			}
		}
	}

	return YES;
}

- (SKNode *) decodeTile:(int)tileUID {
	AZRMapLayerCellShortcut *shortcut = _layer.shortcuts[@(tileUID)];
	NSAssert(shortcut, @"%@ shortcut undefined for layer %@", @(tileUID), self.name);

	SKTexture *texture;
	NSMutableArray *textures = texturesCache[shortcut.identifier];
	if (!textures) {
		textures = [NSMutableArray array];

		int i = 0;
		do {
			//TODO:texture pickup fix
			NSString *textureName = [NSString stringWithFormat:@"ts_%@%i-straight-45.png",shortcut.identifier, i++];
			texture = [AZRSpriteHelper textureNamed:textureName fromAtlasNoPlaceholder:tilesetAtlas];
			if (texture) {
				[textures addObject:texture];
			}
		} while (texture);

		if (![textures count]) {
			[textures addObject:[AZRSpriteHelper textureNamed:shortcut.identifier fromAtlas:tilesetAtlas]];
		}

		texturesCache[shortcut.identifier] = textures;
	}

	texture = textures[arc4random() % [textures count]];
	NSAssert(texture, @"%@ tile has no usable textures for it in texture atlas", shortcut.identifier);

	SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:texture];
	node.anchorPoint = CGPointMake(0.5f, 0.25f);
	if (_showTileShape)
		[node addChild:[self tileShape]];

	return node;
}

- (SKNode *) tileShape {
	SKShapeNode *grid = [SKShapeNode node];
	UIBezierPath *p = [UIBezierPath bezierPath];
	[p moveToPoint:CGPointMake(0, -16)];
	[p addLineToPoint:CGPointMake(32, 0)];
	[p addLineToPoint:CGPointMake(0, 16)];
	[p addLineToPoint:CGPointMake(-32, 0)];
	[p addLineToPoint:CGPointMake(0, -16)];
	grid.path = p.CGPath;
	grid.zPosition = 10000;
	grid.lineWidth = 0.1f;
	grid.strokeColor = [UIColor greenColor];
	grid.fillColor = nil;
	grid.glowWidth = 0.f;
	grid.position = CGPointMake(grid.position.x, grid.position.y);
	return grid;
}

@end

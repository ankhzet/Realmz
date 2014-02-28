//
//  AZRMapLayer.m
//  Realmz
//
//  Created by Ankh on 25.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMapLayer.h"
#import "AZRMapLayerCellShortcut.h"
#import <SpriteKit/SpriteKit.h>

@interface AZRMapLayer () {
	NSMutableDictionary *texturesCache;
}

@end

@implementation AZRMapLayer
@synthesize shortcuts = _shortcuts;
@synthesize gridData = _gridData;
@synthesize width = _width;
@synthesize height = _height;

- (id)init {
	if (!(self = [super init]))
		return self;

	texturesCache = [NSMutableDictionary dictionary];
	return self;
}

- (AZRMapLayerCellShortcut *) addShortcut:(int)uid forIdentifier:(NSString *)identifier {
	if (!_shortcuts)
		_shortcuts = [NSMutableDictionary dictionary];

	AZRMapLayerCellShortcut *shortcut = _shortcuts[@(uid)];
	if (!shortcut) {
		shortcut = [AZRMapLayerCellShortcut new];
		[shortcut setUid:uid];
		[shortcut setIdentifier:identifier];
		_shortcuts[@(uid)] = shortcut;
	} else {
		[shortcut setIdentifier:identifier];
	}
	return shortcut;
}

- (void) setGridData:(NSMutableArray *)gridData {
	if (!_gridData)
		_gridData = [NSMutableArray array];
	else
		[_gridData removeAllObjects];

	_height = [gridData count];
	int w = 0;
	for (NSString *row in gridData) {
    w = MAX(w, [row length]);
		[_gridData addObject:[row mutableCopy]];
	}
	[self makeSureGridContainsPoint:AZRIntPointMake(ceil(w / 2.f), ceil(_height / 2.f))];
}

- (void) pointToRelativeGridPoint:(AZRIntPoint *)point {
	point->x += _width / 2;
	point->y += _height / 2;
}

- (void) makeSureGridContainsPoint:(AZRIntPoint)point {
	int newW = CONSTRAINT((ABS(point.x) + 1) * 2, _width, INT_MAX);
	int newH = CONSTRAINT((ABS(point.y) + 1) * 2, _height, INT_MAX);

	if (!_gridData)
		_gridData = [NSMutableArray array];

	// expand rows if needed
	if (newW != _width) {
		NSMutableArray *rows = [NSMutableArray array];
		for (NSString *row in _gridData) {
			NSUInteger oldLength = [row length];
			NSString *added = [@"" stringByPaddingToLength:(newW - oldLength) withString:@"0" startingAtIndex:0];
			NSString *newRow = [[added stringByReplacingCharactersInRange:NSMakeRange((newW - oldLength) / 2, 0) withString:row] mutableCopy];
			[rows addObject:newRow];
		}
		_gridData = rows;
		_width = newW;
	}

	// add rows if needed
	if (newH != _height) {
		int toAdd = newH - [_gridData count];
		NSString *added = [@"" stringByPaddingToLength:newW withString:@"0" startingAtIndex:0];
		while (toAdd-- > 0) {
			[_gridData addObject:[added mutableCopy]];
			if (toAdd-- > 0)
				[_gridData insertObject:[added mutableCopy] atIndex:0];
		}
		_height = newH;
	}
}

- (NSMutableString *) gridRow:(int)row {
	return _gridData[row + _height / 2];
}

- (int) gridCellRelativeToX:(int)x andY:(int)y {
	unichar c = [_gridData[y] characterAtIndex:x];
	int cell = 0;
	if ((c >= '0') && (c <= '9'))
		cell = c - '0';
	else if ((c >= 'A') && (c <= 'Z'))
		cell = (c - 'A') + 10;
	else if ((c >= 'a') && (c <= 'z'))
		cell = (c - 'a') + 10;

	return cell;
}

- (int) gridCellAtXY:(AZRIntPoint)point {
	[self pointToRelativeGridPoint:&point];
	return [self gridCellRelativeToX:point.x andY:point.y];
}

- (void) setGridCell:(int)cell atXY:(AZRIntPoint)point {
	[self makeSureGridContainsPoint:point];

	[self pointToRelativeGridPoint:&point];
	NSMutableString *row = _gridData[point.y];
	[row replaceCharactersInRange:NSMakeRange(point.x, 1) withString:[@(cell) stringValue]];
}

- (BOOL) buildForTileSize:(CGSize)tileSize {
	if (_tiled)
		for (int ty = 0; ty < _height; ty++) {
			float dy = (ty - _height / 2) * tileSize.height;
			for (int tx = _width - 1; tx >= 0; tx--) {
				int cell = [self gridCellRelativeToX:tx andY:ty];
				if (!cell) continue;
				float dx = (tx - _width / 2) * tileSize.width;
				float x = (dx + dy);
				float y = (dx - dy) / 2.f;
				SKNode *tile = [self decodeTile:cell];
				tile.position = CGPointMake(x, y);
				[self addChild:tile];
			}
		}

	return YES;
}

- (SKNode *) decodeTile:(int)tileUID {
	AZRMapLayerCellShortcut *shortcut = self.shortcuts[@(tileUID)];
	NSAssert(shortcut, @"%@ shortcut undefined for layer %@", @(tileUID), self.name);

	SKTextureAtlas *atlas = texturesCache[@"tileset"];
	if (!atlas) {
		atlas = [SKTextureAtlas atlasNamed:@"tileset"];
		texturesCache[@"tileset"] = atlas;
	}

	NSMutableArray *textures = [NSMutableArray array];
	int i = 0;
	NSString *textureName;
	NSArray *textureNames = [atlas textureNames];
	while ([textureNames containsObject:(textureName = [NSString stringWithFormat:@"ts_%@%i-straight-45.png",shortcut.identifier, i++])]) {
		[textures addObject:[atlas textureNamed:textureName]];
	}

	SKTexture *texture;
	if (![textures count])
		texture = [SKTexture textureWithImageNamed:shortcut.identifier];
	else
		texture = textures[arc4random()%[textures count]];

//	NSAssert([textures count], @"%@ tile has no usable textures for it in texture atlas", shortcut.identifier);

	SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:texture];

	/** /
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
	[node addChild:grid];
	 / **/
	node.anchorPoint = CGPointMake(0.5f, 0.25f);

	return node;
}


@end

//
//  AZRRealmRenderer.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGameRenderer.h"
#import "AZRGame.h"
#import "AZRRealm.h"
#import "AZRObject.h"
#import "AZRObject+VisibleObject.h"
#import "AZRMap.h"
#import "AZRMapLayer.h"
#import "AZRMapChunk.h"
#import "AZRMapLayerRenderer.h"
#import "AZRGUIRenderer.h"
#import "AZRTappableSpriteNode.h"
#import "AZRSpriteHelper.h"


@interface AZRGameRenderer ()
@property int chunkSize;
@property NSMutableArray *chunks;
@end


@implementation AZRGameRenderer

@synthesize chunks = _chunks;
@synthesize chunkSize = _chunkSize;

+ (instancetype) rendererForGame:(AZRGame *)game {
	AZRGameRenderer *instance = [self node];
	instance->_game = game;
	return instance;
}

- (id)init {
	if (!(self = [super init]))
		return self;

	_chunks = [NSMutableArray array];
	_chunkSize = 20;

	_mapRootNode = [SKNode node];
	_realmRootNode = [SKNode node];
	[self addChild:_mapRootNode];
	[self addChild:_realmRootNode];
	return self;
}

- (void) buildForRendering:(CGSize)tileSize {
	int z = 0;
	AZRMap *map = [self.game map];
	for (AZRMapLayer *layer in [map.layers allValues]) {
		AZRMapLayerRenderer *renderer = [AZRMapLayerRenderer rendererForMapLayer:layer];
    [renderer buildForTileSize:tileSize];
		renderer.zPosition = z++;
		[_mapRootNode addChild:renderer];
	}

	AZRMapChunk *chunk = [AZRMapChunk chunkForGame:self.game withSize:_chunkSize andOffset:AZRIntPointMake(0, 0)];
	[self.chunks addObject:chunk];

	for (AZRMapChunk *chunk in self.chunks) {
		[chunk buildForTileSize:tileSize];
		chunk.position = CGPointMake(- tileSize.width * chunk->offsetX, - tileSize.height * chunk->offsetY);
    [_realmRootNode addChild:chunk];
	}
}

- (AZRIntPoint) cellToChunk:(AZRIntPoint)cellXY {
	cellXY.x = truncf(cellXY.x / _chunkSize);
	cellXY.y = truncf(cellXY.y / _chunkSize);
	return cellXY;
}

- (NSArray *) chunkAt:(CGPoint)pointXY {
	AZRIntPoint chunkXY = [self cellToChunk:AZRIntPointMake(pointXY.x, pointXY.y)];
	chunkXY.x = CONSTRAINT(chunkXY.x, 0, [self.game map].width / _chunkSize);
	chunkXY.y = CONSTRAINT(chunkXY.y, 0, [self.game map].height / _chunkSize);
	return _chunks[chunkXY.y][chunkXY.x];
}

#pragma mark - Processing

- (void) processed:(CFTimeInterval)currentTime {
	int mapHeight = [self.game map].height;
	int i = 0;
	for (AZRObject *o in [[self.game realm] allObjects]) {
		if (!(o->alive)) {
			if (o->renderBody && ![o->renderBody hasActions]) {
				SKAction *fadeOutAction = [SKAction fadeOutWithDuration:0.25f];
				SKAction *blockAction = [SKAction runBlock:^{
					o->renderBody = nil;
					[[self.game realm] killObject:o];
				}];
				[o->renderBody runAction:[SKAction sequence:@[fadeOutAction, blockAction]]];
			}
		}

		CGPoint pos = [o coordinates];

		pos = cartXYtoIsoXY(pos);
		pos.x = (pos.x - 1.0f) * tileSize.width;
		pos.y = (pos.y - 0.0f) * tileSize.height;
		SKNode *objectBody;
		if (!(objectBody = o->renderBody)) {
			objectBody = o->renderBody = [self bodyForObject:o.classDescription];
			objectBody.position = pos;
			SKAction *fadeInAction = [SKAction fadeInWithDuration:0.25f];

			objectBody.alpha = 0.f;
			[objectBody runAction:fadeInAction];
			[self.realmRootNode addChild:objectBody];
			i++;
		} else
			objectBody.position = pos;

		objectBody.zPosition = - pos.y + tileSize.height * mapHeight / 2;
	}
	[AZRLogger log:NSStringFromClass([self class]) withMessage:@"Attached %i bodies to objects", i];
}

- (SKNode *) bodyForObject:(AZRObjectClassDescription *)objectClassIdentifier {
	SKSpriteNode *node;
	SKTexture *texture;
	@try {
		AZRObjectProperty *textureProperty = [objectClassIdentifier hasProperty:@"texture"];
		NSString *texturePattern = [textureProperty stringValue];
		NSArray *searchWith = [texturePattern componentsSeparatedByString:@":"];

		texture = [AZRSpriteHelper textureNamed:searchWith[1] fromAtlas:searchWith[0]];
		node = [SKSpriteNode spriteNodeWithTexture:texture];
		node.anchorPoint = [AZRSpriteHelper getAnchorForTexture:searchWith[1] inAtlas:searchWith[0]];
	}
	@catch (NSException *exception) {
    texture = [SKTexture textureWithImageNamed:objectClassIdentifier.name];
		node = [SKSpriteNode spriteNodeWithTexture:texture];
	}
	return node;
}


-(void)update:(CFTimeInterval)currentTime {
	//TODO: show actions, performed by actor

	/* needs render snippet
	Class isActor = [AZRActor class];
	NSNumber *bYes = @(YES);
	NSNumber *bNo = @(NO);

	if ([self.selection count]) {
		for (AZRObject *selected in self.selection) {
//		BOOL isActor = [o isKindOfClass:[AZRActor class]];

			if ([selected isKindOfClass:isActor]) {
				NSDictionary *needs = [(AZRActor *)selected pickImportantNeeds];
				NSArray *critical = needs[bYes];
				NSArray *normal = needs[bNo];

				NSString *c = @"";
				for (AZRActorNeed *need in critical) {
					c = [NSString stringWithFormat:@"%@\n%@!", c, need.name];
				}
				for (AZRActorNeed *need in normal) {
					c = [NSString stringWithFormat:@"%@\n%@", c, need.name];
				}
				NSSize textBox = [c sizeWithAttributes:nil];

				CGFloat cx = pos.x - textBox.width / 2;
				CGFloat cy = pos.y + radius;

				[c drawAtPoint:NSMakePoint(cx, cy) withAttributes:textAttr];
			}
		}

	}

	*/
}



/*
- (void) rightMouseDown:(NSEvent *)event {
	if (![self acceptsControl:@selector(rightClicked:atCoordinates:)])
		return;

	CGPoint tapLocation = [event locationInWindow];
	tapLocation = [self convertPoint:tapLocation fromView:nil];

	NSArray *picked = [self->realm overlapsWith:tapLocation withDistanceOf:5.f];
	[self.delegate rightClicked:picked atCoordinates:tapLocation];
 }

- (BOOL) acceptsControl:(SEL)selector {
	return self.delegate && [self.delegate respondsToSelector:selector];
}*/

@end

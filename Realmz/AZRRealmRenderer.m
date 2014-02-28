//
//  AZRRealmRenderer.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRRealmRenderer.h"

#import "AZRRealm.h"
#import "AZRObject.h"
#import "AZRObject+VisibleObject.h"
#import "AZRMap.h"
#import "AZRMapLoader.h"
#import "AZRTappableSpriteNode.h"
#import "AZRGUIRenderer.h"
#import "AZRSpriteHelper.h"

@interface AZRRealmRenderer () {
	__weak AZRRealm *realm;
	AZRMap *map;
	CGPoint scrollStart;
	CGSize viewSize;

	BOOL ctlMoving;
	BOOL ctlScrolling;

	SKNode *objectsRootNode;
	SKNode *mapRootNode;
	SKNode *viewRootNode;

	AZRGUIRenderer *gui;
}
@end
@implementation AZRRealmRenderer

- (void) attachToRealm:(AZRRealm *)_realm {

	realm = _realm;

	map = [[AZRMapLoader new] loadFromFile:@"map01"];
	map.realm = realm;
	[map buildForRendering:tileSize];
	[viewRootNode addChild:map.graphicsNode];

	map.graphicsNode.zPosition = 0;
	objectsRootNode.zPosition = 1;
	viewRootNode.position = CGPointMake(viewSize.width / 2, viewSize.height / 2);
	viewRootNode.zPosition = 0;
	
	gui.realm = realm;
}

-(id)initWithSize:(CGSize)size {
	if (!(self = [super initWithSize:size]))
		return self;

	self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

	viewRootNode = [SKNode node];
	objectsRootNode = [SKNode node];
	[viewRootNode addChild:objectsRootNode];

	[self addChild:viewRootNode];

	gui = [AZRGUIRenderer new];
	[self addChild:gui.graphicsNode];
	gui.delegate = self;
	gui.actionsRenderer.delegate = self;

	viewSize = size;
	return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint tapLocation = [touch locationInNode:self];

	if (ctlScrolling) {
		scrollStart = tapLocation;
		return;
	}

	[gui beginSelection:tapLocation withMapScroll:viewRootNode.position andTileSize:tileSize];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[gui endSelection];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[gui endSelection];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint tapLocation = [touch locationInNode:self];

	if (ctlScrolling) {
		CGPoint prev = viewRootNode.position;
		viewRootNode.position = CGPointMake(prev.x + (tapLocation.x - scrollStart.x), prev.y + (tapLocation.y - scrollStart.y));
		scrollStart = tapLocation;
		return;
	}

	BOOL onePicked = [gui.selection count] == 1;
	if (onePicked && ![gui isSelecting]) {
		if (ctlMoving) {
			[gui.selection[0] moveToXY:tapLocation];
		}
		return;
	}

	[gui updateSelection:tapLocation withMapScroll:viewRootNode.position andTileSize:tileSize];
}

- (void) processed:(CFTimeInterval)currentTime {
	[gui update:viewSize forCurrentTime:currentTime];
	int i = 0;
	for (AZRObject *o in [realm allObjects]) {
		CGPoint pos = [o coordinates];

		pos = cartXYtoIsoXY(pos);
		pos.x = (pos.x - 1.0f) * tileSize.width;
		pos.y = (pos.y - 0.0f) * tileSize.height;
		SKNode *objectBody;
		if (!(objectBody = o->renderBody)) {
			objectBody = o->renderBody = [self bodyForObject:o.classDescription];
			objectBody.position = pos;
			[objectsRootNode addChild:objectBody];
			i++;
		} else
			objectBody.position = pos;

		objectBody.zPosition = - pos.y + tileSize.height * map.height / 2;
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


- (BOOL) onBuildPlaceHitTest:(UITouch *)hitTouch mapXY:(CGPoint *)mapXY constrainedXY:(CGPoint *)constrained {
	CGPoint inViewLocation = [hitTouch locationInNode:self];
	CGPoint delta = *constrained;
	delta.x -= inViewLocation.x;
	delta.y -= inViewLocation.y;
	inViewLocation.x -= viewRootNode.position.x;
	inViewLocation.y -= viewRootNode.position.y;

	*mapXY = isoXYtoCartXY(inViewLocation);
	mapXY->x = ((int)(ceilf(mapXY->x / tileSize.width) + 0.0f));
	mapXY->y = ((int)(ceilf(mapXY->y / tileSize.height) - 0.f));
	*constrained = cartXYtoIsoXY(*mapXY);
	constrained->x = (int)((constrained->x - 1.0f) * tileSize.width);
	constrained->y = (int)((constrained->y + 0.f) * tileSize.height);
	constrained->x += viewRootNode.position.x + delta.x;
	constrained->y += viewRootNode.position.y + delta.y;

	return ![[realm overlapsWith:*mapXY withDistanceOf:1.f] count];
}

- (void) guiCtlPressed:(AZRTappableSpriteNode *)ctl {
	if ([ctl.name isEqualToString:@"map-scroll"]) {
		ctlScrolling = !ctlScrolling;
	}
}

- (void) guiCtlReleased:(AZRTappableSpriteNode *)ctl {
	if ([ctl.name isEqualToString:@"map-scroll"]) {
//		ctlScrolling = NO;
	}
}

-(void)update:(CFTimeInterval)currentTime {
}

@end

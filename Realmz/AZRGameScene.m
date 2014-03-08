//
//  AZRGameScene.m
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGameScene.h"
#import "AZRGame.h"
#import "AZRRealm.h"
#import "AZRGUIRenderer.h"
#import "AZRGameRenderer.h"
#import "AZRMapCommons.h"
#import "AZRGUIConstants.h"
#import "AZRObject+VisibleObject.h"
#import "AZRTappableSpriteNode.h"

@interface AZRGameScene () {
	CGPoint scrollStart;
	BOOL ctlMoving;
	BOOL ctlScrolling;
	SKNode *sceneTreeContainer;
}

@end

@implementation AZRGameScene

#pragma mark - Instantiation

+ (instancetype) sceneForGame:(AZRGame *)game withSize:(CGSize)size {
	AZRGameScene *scene = [self sceneWithSize:size];
	scene.game = game;
	return scene;
}

-(id)initWithSize:(CGSize)size {
	if (!(self = [super initWithSize:size]))
		return self;

	self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
	sceneTreeContainer = [SKNode node];
	[self addChild:sceneTreeContainer];

	return self;
}

- (void) setGame:(AZRGame *)game {
	_game = game;
	_gameRenderer = [AZRGameRenderer rendererForGame:_game];
	_gameRenderer.position = CGPointMake(self.size.width / 2, self.size.height / 2);
	[_gameRenderer buildForRendering:tileSize];

	_guiRenderer = [AZRGUIRenderer rendererForGame:_game];
	_guiRenderer.delegate = self;
	_guiRenderer.actionsRenderer.delegate = self;

	[sceneTreeContainer addChild:_gameRenderer];
	[sceneTreeContainer addChild:_guiRenderer];

}

#pragma mark - Processing

- (void) process:(NSTimeInterval)currentTime {
	CGSize viewSize = self.size;
	float scale = MIN(viewSize.width, viewSize.height) / DESIGNED_FOR_RESOLUTION;
	scale *= 2.f - scale;

	viewSize.width /= scale;
	viewSize.height /= scale;
	[sceneTreeContainer setScale:scale];

	[_gameRenderer processed:currentTime];
	[_guiRenderer update:viewSize forCurrentTime:currentTime];
}

#pragma mark - Scene overrides

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (ctlScrolling) {
		UITouch *touch = [touches anyObject];
		CGPoint tapLocation = [touch locationInNode:sceneTreeContainer];
		scrollStart = tapLocation;
		return;
	}

	[_guiRenderer touchesBegan:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[_guiRenderer touchesCancelled:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[_guiRenderer touchesEnded:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint tapLocation = [touch locationInNode:sceneTreeContainer];

	if (ctlScrolling) {
		CGPoint prev = _gameRenderer.position;
		_gameRenderer.position = CGPointMake(prev.x + (tapLocation.x - scrollStart.x), prev.y + (tapLocation.y - scrollStart.y));
		scrollStart = tapLocation;
		return;
	}

	BOOL onePicked = [_guiRenderer.selection count] == 1;
	if (onePicked && ![_guiRenderer isSelecting]) {
		if (ctlMoving) {
			[_guiRenderer.selection[0] moveToXY:tapLocation];
		}
		return;
	}

	[_guiRenderer touchesMoved:touches withEvent:event];
}

#pragma mark - GUIRenderer delegate methods

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

- (CGPoint) mapScrolledTo {
	return _gameRenderer.position;
}

#pragma mark - GUIActionsRenderer delegate methods

- (BOOL) onBuildPlaceHitTest:(UITouch *)hitTouch mapXY:(CGPoint *)mapXY constrainedXY:(CGPoint *)constrained {
	CGPoint inViewLocation = [hitTouch locationInNode:sceneTreeContainer];
	CGPoint delta = *constrained;
	delta.x -= inViewLocation.x;
	delta.y -= inViewLocation.y;
	inViewLocation.x -= _gameRenderer.position.x;
	inViewLocation.y -= _gameRenderer.position.y;

	*mapXY = isoXYtoCartXY(inViewLocation);
	mapXY->x = ((int)(ceilf(mapXY->x / tileSize.width) + 0.0f));
	mapXY->y = ((int)(ceilf(mapXY->y / tileSize.height) - 0.f));
	*constrained = cartXYtoIsoXY(*mapXY);
	constrained->x = (int)((constrained->x - 1.0f) * tileSize.width);
	constrained->y = (int)((constrained->y + 0.f) * tileSize.height);
	constrained->x += _gameRenderer.position.x + delta.x;
	constrained->y += _gameRenderer.position.y + delta.y;

	return ![[[self.game realm] overlapsWith:*mapXY withDistanceOf:1.f] count];
}

@end

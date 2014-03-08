//
//  AZRGUIRenderer.m
//  Realmz
//
//  Created by Ankh on 25.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AZRGUIRenderer.h"
#import "AZRGUIActionsRenderer.h"
#import "AZRGUIConstants.h"
#import "AZRMapCommons.h"
#import "AZRGame.h"
#import "AZRRealm.h"
#import "AZRObject.h"
#import "AZRObject+VisibleObject.h"
#import "AZRTappableSpriteNode.h"
#import "AZRGUIResourcesRenderer.h"
#import "AZRPlayer.h"
#import "AZRPlayerState.h"

@interface AZRGUIRenderer () {
	BOOL select;
	CGPoint selStart;
	SKNode *selectionNode;
	SKNode *minimapNode;
	AZRTappableSpriteNode *scrollNode;
	SKTextureAtlas *guiAtlas, *actionsAtlas, *buildingsAtlas;
	CGSize viewSize;
	BOOL selectionModified;
	SKNode *focusNode;
}

@end
@implementation AZRGUIRenderer

+ (instancetype) rendererForGame:(AZRGame *)game {
	AZRGUIRenderer *renderer = [[self alloc] initForGame:game];
	return renderer;
}

- (id)initForGame:(AZRGame *)game {
	if (!(self = [super init]))
		return self;

	_game = game;

	select = NO;
	selectionModified = NO;
	self.selection = [NSMutableArray array];

	guiAtlas = [SKTextureAtlas atlasNamed:@"gui"];
	actionsAtlas = [SKTextureAtlas atlasNamed:@"actions"];
	buildingsAtlas = [SKTextureAtlas atlasNamed:@"buildings"];

	selectionNode = [SKNode node];
	minimapNode = [SKSpriteNode spriteNodeWithTexture:[guiAtlas textureNamed:@"minimap-bg"]];

	selectionNode.zPosition = ZINDEX_SELECTION;
	minimapNode.zPosition = ZINDEX_GUICOMMON;

	_actionsRenderer = [AZRGUIActionsRenderer actionsRendererForGame:_game];

	_resourcesRenderer = [AZRGUIResourcesRenderer node];

	scrollNode = [self makeGUIControl:@"button-normal" forCommand:@"map-scroll"];
	scrollNode.position = CGPointMake(scrollNode.size.width, scrollNode.size.height);

	[self addChild:selectionNode];
	[self addChild:minimapNode];
	[self addChild:_actionsRenderer];
	[self addChild:_resourcesRenderer];
	[self addChild:scrollNode];

	return self;
}

- (AZRTappableSpriteNode *) makeGUIControl:(NSString *)sprite forCommand:(NSString *)command {
	AZRTappableSpriteNode *node = [AZRTappableSpriteNode spriteNodeWithImageNamed:sprite];
	node.name = command;
	node.zPosition = ZINDEX_GUITOPLAYER;
	__block __weak AZRGUIRenderer *weakSelf = self;
	[node setTapBeginCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		if (weakSelf.delegate) {
			[weakSelf.delegate guiCtlPressed:sender];
		}
	}];
	[node setTapEndCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		if (weakSelf.delegate) {
			[weakSelf.delegate guiCtlReleased:sender];
		}
	}];
  return node;
}

- (void) update:(CGSize)viewFrameSize forCurrentTime:(CFTimeInterval)currentTime {
	viewSize = viewFrameSize;
//	float scale = 1.5 * MIN(viewSize.width, viewSize.height) / DESIGNED_FOR_RESOLUTION;
//	[self setScale:scale];
//	viewSize.width /= scale;
//	viewSize.height /= scale;
	[self updateSubLayers];
	[self updateMinimap];

	if ([self.selection count]) {
		[self updateSelectionDetails];
	}
	if (selectionModified) {
		selectionModified = NO;
		if ([self.selection count]) {
			[_actionsRenderer updateActions:self.selection inViewWithSize:viewSize];
		} else
			[_actionsRenderer clearActions];
	}

	[_resourcesRenderer updateResources:[_game getHumanPlayer].state.resourcesManager viewSize:viewSize];
}

- (void) updateMinimap {
	CGSize minimapSize = minimapNode.frame.size;
	minimapNode.position = CGPointMake(viewSize.width - minimapSize.width / 2.f - GUI_MARGIN, viewSize.height - minimapSize.height / 2.f - GUI_MARGIN);
}

#pragma mark - Input handling

- (SKNode *) uiNodeAtPoint:(CGPoint)p inParent:(SKNode *)parent {
	NSArray *array = [parent nodesAtPoint:p];
	NSMutableArray *uiResponsible = [NSMutableArray array];
  for (SKNode *child in array) {
    if ([child isUserInteractionEnabled]) {
			[uiResponsible addObject:child];
		}
	}

	[uiResponsible sortUsingComparator:^NSComparisonResult(SKNode *node1, SKNode *node2) {
		float delta = node1.zPosition - node2.zPosition;
		return (delta != 0) ? delta / ABS(delta) : NSOrderedSame;
	}];

	return [uiResponsible count] ? uiResponsible[0] : nil;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *node = [self uiNodeAtPoint:location inParent:self];

	focusNode = node;
	if (focusNode) {
		[focusNode touchesBegan:touches withEvent:event];
	} else {
		[self beginSelection:location withMapScroll:[self.delegate mapScrolledTo] andTileSize:tileSize];
	}
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (focusNode) {
		[focusNode touchesCancelled:touches withEvent:event];
	} else {
		[self endSelection];
	}
	focusNode = nil;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (focusNode) {
		[focusNode touchesEnded:touches withEvent:event];
	} else {
		[self endSelection];
	}
	focusNode = nil;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (focusNode) {
		[focusNode touchesMoved:touches withEvent:event];
	} else {
		UITouch *touch = [touches anyObject];
		CGPoint location = [touch locationInNode:self];
		[self updateSelection:location withMapScroll:[self.delegate mapScrolledTo] andTileSize:tileSize];
	}
}


#pragma mark - Sublayers

- (void) updateSubLayers {

}

#pragma mark - Selection details

- (void) updateSelectionDetails {
	[_actionsRenderer updateActionsProgressInViewWithSize:viewSize];
/*	self.needs = nil;
	BOOL oneSelected = [self.realmRenderer.gui.selection count] == 1;
	if (oneSelected) {
		self.object = self.realmRenderer.selection[0];

		NSMutableArray *data = [NSMutableArray array];
		if ([self.object isKindOfClass:[AZRActor class]]) {
			for (AZRActorNeed *need in [((AZRActor *)self.object).needs allValues]) {
				[data addObject:@{@"name":need.name, @"value": [NSString stringWithFormat:@"%.2f", need.currentValue]}];
			}
		}

		for (AZRObjectProperty *p in [self.object.properties allValues]) {
			NSString *value = [[[[[[p description]
														 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
														stringByReplacingOccurrencesOfString:p.name withString:@""]
													 stringByReplacingOccurrencesOfString:@":" withString:@""]
													stringByReplacingOccurrencesOfString:@" " withString:@""]
												 stringByReplacingOccurrencesOfString:@"*" withString:@""];
			[data addObject:@{@"name": p.name, @"value": value}];
		}
		self.needs = data;
	}
*/
}

#pragma mark - Selection handling

- (BOOL) isSelecting {
	return select;
}

- (void) hiliteSelection {
	for (AZRObject *object in self.selection) {
    if (object->renderBody) {
			if (![[((SKNode *)object->renderBody) children] count])
				[self highliteNode:object->renderBody withColor:[UIColor colorWithRed:0.5f green:1.f blue:0.5f alpha:1.f] withDuration:0.5f];
		}
	}
}

- (void) clearSelection {
	for (AZRObject *object in self.selection) {
    if (object->renderBody) {
			[self removeHilition:object->renderBody];
		}
	}
	[self.selection removeAllObjects];
	selectionModified = YES;
}

- (void) beginSelection:(CGPoint)tapLocation withMapScroll:(CGPoint)scrollOffset andTileSize:(CGSize)tileSize {
	NSArray *picked = [[_game realm] filterWithBlock:^BOOL(AZRObject *object, BOOL *stop) {
		CGPoint pos = [object coordinates];
		pos = cartXYtoIsoXY(pos);
		pos.x = (pos.x - 0.5) * tileSize.width;
		pos.y = (pos.y) * tileSize.height;

		CGPoint tap = CGPointMake(tapLocation.x - scrollOffset.x, tapLocation.y - scrollOffset.y);
		return SQR(tap.x - pos.x) + SQR(tap.y - pos.y) <= SQR([object radius] * tileSize.width + 5.f);
	}];
	select = ![picked count]; // if no objects under tap - show selection frame
	selStart = CGPointMake((int)tapLocation.x, (int)tapLocation.y);

	[self clearSelection];
	if (!select) { // there are objects under tap
		[self.selection addObject:picked[0]];
	}
	[self hiliteSelection];
}

- (void) endSelection {
	select = NO;
	[selectionNode removeAllChildren];
}

- (void) updateSelection:(CGPoint)tapLocation withMapScroll:(CGPoint)scrollOffset andTileSize:(CGSize)tileSize {
	if (!select)
		return;

	tapLocation = CGPointMake((int)tapLocation.x, (int)tapLocation.y);
	CGFloat x = MIN(selStart.x, tapLocation.x);
	CGFloat y = MIN(selStart.y, tapLocation.y);
	CGFloat w = ABS(selStart.x - tapLocation.x);
	CGFloat h = ABS(selStart.y - tapLocation.y);
	CGRect r = CGRectMake(x, y, w, h);
	NSArray *inRectObjects = [[_game realm] filterWithBlock:^BOOL(AZRObject *object, BOOL *stop) {
		CGPoint pos = [object coordinates];
		pos = cartXYtoIsoXY(pos);
		pos.x = (pos.x - 0.5) * tileSize.width;
		pos.y = (pos.y) * tileSize.height;

		CGRect rect = CGRectOffset(r, - scrollOffset.x, - scrollOffset.y);
		return CGRectContainsPoint(CGRectInset(rect, - [object radius], - [object radius]), pos);
	}];
	if ([inRectObjects count] > 0) {
		inRectObjects = [inRectObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSUInteger d1 = ((AZRObject *)obj1).classDescription.multiSelectionGroup;
			NSUInteger d2 = ((AZRObject *)obj2).classDescription.multiSelectionGroup;
			return (d1 > d2) ? NSOrderedAscending : ((d1 < d2) ? NSOrderedDescending : NSOrderedSame);
		}];

		NSUInteger preferGroup = ((AZRObject *)inRectObjects[0]).classDescription.multiSelectionGroup;

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"classDescription.multiSelectionGroup = %lu", preferGroup];

		[self clearSelection];
		self.selection = [[inRectObjects filteredArrayUsingPredicate:predicate] mutableCopy];
		[self hiliteSelection];
	} else
		[self clearSelection];

	SKShapeNode *selection = [SKShapeNode node];
	selection.path = [UIBezierPath bezierPathWithRect:r].CGPath;
	selection.strokeColor = [UIColor greenColor];
	selection.fillColor = nil;
	selection.lineWidth = 1;
	selection.glowWidth = 0;
	[selectionNode removeAllChildren];
	[selectionNode addChild:selection];
}

#pragma mark Nodes highlightion

- (void) highliteNode:(SKSpriteNode *)node withColor:(UIColor *)color withDuration:(float)duration {
	SKAction *fadeInSelection = [SKAction fadeAlphaTo:1.f duration:duration / 2.f];
	SKAction *fadeOutSelection = [SKAction fadeAlphaTo:0.f duration:duration / 2.f];
  SKAction *selectAction = [SKAction sequence:@[fadeInSelection, fadeOutSelection]];
	//	SKAction *fadeInSelection2 = [SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:0.2f duration:duration / 2.f];
	//	SKAction *fadeOutSelection2 = [SKAction colorizeWithColorBlendFactor:0.f duration:duration / 2.f];
	//  SKAction *selectAction2 = [SKAction sequence:@[fadeInSelection2, fadeOutSelection2]];

	CGSize size = node.frame.size;
	size.width = (size.width + 8.f) / size.width;
	size.height = (size.height + 8.f) / size.height;
	float offset = MAX(size.width, size.height);

	SKNode *hilition = [SKSpriteNode node];
	SKSpriteNode *n1 = [node copy];
	n1.zPosition = - 1;
	SKSpriteNode *n2 = [n1 copy];
	SKSpriteNode *n3 = [n1 copy];
	SKSpriteNode *n4 = [n1 copy];
	n1.position = CGPointMake(-offset, -offset);
	n2.position = CGPointMake(-offset,  offset);
	n3.position = CGPointMake( offset,  offset);
	n4.position = CGPointMake( offset, -offset);
	n1.color = color;
	n2.color = color;
	n3.color = color;
	n4.color = color;
	n1.blendMode = SKBlendModeAdd;
	n2.blendMode = SKBlendModeAdd;
	n3.blendMode = SKBlendModeAdd;
	n4.blendMode = SKBlendModeAdd;
	[hilition addChild:n1];
	[hilition addChild:n2];
	[hilition addChild:n3];
	[hilition addChild:n4];

	hilition.zPosition = -1;
	[node removeAllChildren];
	[node addChild:hilition];

	[hilition runAction:[SKAction repeatActionForever:selectAction]];
	//	[node removeAllActions];
	//	[node setColorBlendFactor:0.f];
	//	[node runAction:[SKAction repeatActionForever:selectAction2]];
}

- (void) removeHilition:(SKSpriteNode *)node {
	[node removeAllChildren];
	//	[node removeAllActions];
	//	[node setColorBlendFactor:0.f];
}


@end

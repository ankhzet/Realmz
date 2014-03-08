//
//  AZRGUIActionsRenderer.m
//  Realmz
//
//  Created by Ankh on 28.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGUIActionsRenderer.h"
#import "AZRGUIConstants.h"
#import "AZRTappableSpriteNode.h"
#import "AZRSpriteHelper.h"
#import "AZRObject.h"
#import "AZRMapCommons.h"
#import "AZRGame.h"
#import "AZRRealm.h"
#import "AZRTechTree.h"
#import "AZRTechnology.h"
#import "AZRPlayer.h"
#import "AZRPlayerState.h"

#define ACTION_TECH 1
#define ACTION_ACTION 2

#define INVOKER_ACTION_NODE 1

@interface AZRGUIActionsRenderer () {
	SKNode *actionsNode;
	SKNode *actionPopupNode;
	CGSize actionButtonSize;
	SKTexture *actionBg;
	SKTexture *unknownActionIcon;
	SKTexture *actionProgress;
  SKShapeNode *iterationsCountBGShape;
}

@end
@implementation AZRGUIActionsRenderer

static NSString *GUI_ATLAS = @"gui";

#pragma mark - Instantiation

+ (instancetype) actionsRendererForGame:(AZRGame *)game {
	AZRGUIActionsRenderer *renderer = [[self alloc] initForGame:game];
	return renderer;
}

- (id)initForGame:(AZRGame *)game {
	if (!(self = [super init]))
		return self;

	_game = game;

	actionsNode = [SKNode node];
	actionsNode.zPosition = ZINDEX_GUICOMMON;
	actionBg = [AZRSpriteHelper textureNamed:@"action-bg" fromAtlas:GUI_ATLAS];
	unknownActionIcon = [AZRSpriteHelper textureNamed:@"button-disabled" fromAtlas:GUI_ATLAS];
	actionProgress = [SKTexture textureWithImageNamed:@"action-progress.png"];

	actionButtonSize = actionBg.size;
	actionButtonSize.width += ACTIONS_OUTSET;
	actionButtonSize.height += ACTIONS_OUTSET;
	[self addChild:actionsNode];


	[self initActionPopup];
	[self addChild:actionPopupNode];

	CGRect nodeRect = CGRectMake(0, 0, actionButtonSize.width, 12.f);
	UIBezierPath *iterationsCountPath = [UIBezierPath bezierPathWithRoundedRect:nodeRect cornerRadius:4.f];

	iterationsCountBGShape = [SKShapeNode node];
	iterationsCountBGShape.name = @"iterations";
	iterationsCountBGShape.path = iterationsCountPath.CGPath;
	iterationsCountBGShape.strokeColor = [UIColor blackColor];
//	iterationsCountBGShape.fillColor = [UIColor whiteColor];
	iterationsCountBGShape.glowWidth = 0.f;
	iterationsCountBGShape.lineWidth = 0.f;

	SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	label.fontSize = 12.f;
	label.fontColor = [UIColor blackColor];
	label.name = @"count";
	label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
	[iterationsCountBGShape addChild:label];


	return self;
}

- (SKTexture *) findActionAsociatedIcon:(NSString *)action withAnchors:(CGPoint *)anchors {
	*anchors = CGPointMake(0.5f, 0.5f);
	SKTexture *actionIcon = unknownActionIcon;
	NSString *textureName = [NSString stringWithFormat:@"%@.png", action];
	for (NSString *atlas in @[@"actions", @"buildings", GUI_ATLAS]) {
		SKTexture *tex = [AZRSpriteHelper textureNamed:textureName fromAtlasNoPlaceholder:atlas];
		if (tex) {
			actionIcon = tex;
			*anchors = [AZRSpriteHelper getAnchorForTexture:[textureName stringByDeletingPathExtension] inAtlas:atlas];
			break;
		}
	}
	return actionIcon;
}

#pragma mark - Action summary & popup

static NSString *actionPopupAnchorNodeUID = @"popup-anchor";
static NSString *actionPopupContentsNodeUID = @"popup-contents";
static NSString *actionPopupIconNodeUID = @"popup-dragged-icon";

- (void) placePopup:(CGPoint)anchor {
	CGSize popupSize = actionPopupNode.frame.size;
	float popupX = anchor.x - (popupSize.width + actionButtonSize.width + ACTIONS_OUTSET) / 2.f;
	float anchorY = anchor.y;
	float popupY = MAX(GUI_MARGIN, anchor.y - popupSize.height / 2.f) + popupSize.height / 2.f;
	float delta = anchorY - popupY;
	SKNode *anchorNode = [actionPopupNode childNodeWithName:actionPopupAnchorNodeUID];
	anchorNode.position = CGPointMake(anchorNode.position.x, delta);
	actionPopupNode.position = CGPointMake((int)popupX, (int)popupY);
	actionPopupNode.hidden = NO;
}

- (void) initActionPopup {
	actionPopupNode = [SKSpriteNode spriteNodeWithTexture:[AZRSpriteHelper textureNamed:@"action-popup" fromAtlas:GUI_ATLAS]];
	actionPopupNode.zPosition = ZINDEX_GUITOPLAYER;

	actionPopupNode.hidden = YES;
	CGSize popupSize = actionPopupNode.frame.size;

	SKNode *anchor = [SKSpriteNode spriteNodeWithTexture:[AZRSpriteHelper textureNamed:@"action-popup-anchor" fromAtlas:GUI_ATLAS]];
	anchor.name = actionPopupAnchorNodeUID;
	anchor.position = CGPointMake(popupSize.width / 2.f - 2.5f, 0);
	[actionPopupNode addChild:anchor];

	SKNode *contents = [SKNode node];
	contents.name = actionPopupContentsNodeUID;
	[actionPopupNode addChild:contents];
}

/*!
 @brief Hide tech summary pop-up.
 */
- (void) hideTechSummary {
	actionPopupNode.hidden = YES;
	actionPopupNode.position = CGPointMake(-1000, -1000);
}

/*!
 @brief Show tech summary pop-up.
 @param actionNode Action invoking node to place in pop-up.
 @param anchor Coordinates of anchor point for pop-up (bottom-right corner of pop-up).
 */
- (void) showTechSummary:(SKNode *)actionNode anchoredAt:(CGPoint)anchor {
	SKNode *contents = [actionPopupNode childNodeWithName:actionPopupContentsNodeUID];
	[contents removeAllChildren];

	CGSize size = actionPopupNode.frame.size;
	size.width *= 0.8;
	size.height *= 0.8;

	actionNode.position = CGPointMake((size.width - actionButtonSize.width) / 2.f, (size.height - actionButtonSize.height) / 2.f);
	[contents addChild:actionNode];

	[self placePopup:anchor];
}

- (BOOL) toggleTechSummary:(SKNode *)actionNode anchoredAt:(CGPoint)anchor {
	if (actionPopupNode.hidden) {
		[self showTechSummary:actionNode anchoredAt:anchor];
	} else
		[self hideTechSummary];

	return !actionPopupNode.hidden;
}

- (AZRTappableSpriteNode *) actionInvoker:(NSString *)iconName {
	AZRTappableSpriteNode *actionNode = [AZRTappableSpriteNode spriteNodeWithImageNamed:@"button-normal"];
	CGPoint iconAnchor = CGPointZero;
	SKSpriteNode *actionIcon = [SKSpriteNode spriteNodeWithTexture:[self findActionAsociatedIcon:iconName withAnchors:&iconAnchor]];
	actionIcon.name = actionPopupIconNodeUID;
	actionIcon.anchorPoint = iconAnchor;
	float iconScale = scaleToFit(actionIcon.size, actionNode.size, 0.8);
	[actionIcon setScale:iconScale];
	[actionNode addChild:actionIcon];
	return actionNode;
}

#pragma mark Action nodes

- (AZRTechTree *) humanPlayerTechTree {
	AZRPlayerState *playerState = [self.game getHumanPlayer].state;
	return playerState.techTree;
}

- (void) clearActions {
  [actionsNode removeAllChildren];
	[self hideTechSummary];
}

- (SKNode *) actionNodeProvidedBy:(AZRObject *)object withParameters:(NSArray *)parameters {
	NSString *iconName = parameters[0];
	NSString *actionType = parameters[1];

	SKNode *node = [SKNode node];
	AZRTappableSpriteNode *bg = [AZRTappableSpriteNode spriteNodeWithTexture:actionBg];
	CGPoint iconAnchor = CGPointZero;
	SKTexture *actionIcon = [self findActionAsociatedIcon:iconName withAnchors:&iconAnchor];
	SKSpriteNode *icon = [SKSpriteNode spriteNodeWithTexture:actionIcon];
	[icon setScale:scaleToFit(actionIcon.size, actionButtonSize, 0.8f)];
	[node addChild:bg];
	[bg addChild:icon];

	AZRTappableSpriteNode *actionInvoker = [self actionInvoker:iconName];
	actionInvoker.userData = [@{@(INVOKER_ACTION_NODE): node} mutableCopy];

	if ([actionType isEqualToString:@"tech"]) {
		NSString *techName = parameters[2];
		parameters = [[parameters subarrayWithRange:NSMakeRange(3, [parameters count] - 3)] mutableCopy];
		AZRTechnology *tech = [[self humanPlayerTechTree] techNamed:techName];
		if (tech) {
			node.userData = [NSMutableDictionary dictionaryWithObjects:@[tech] forKeys:@[@(ACTION_TECH)]];
//			node.userData = [@{@(ACTION_TECH): tech} mutableCopy];
			id target = object;
			if ([tech requiresTarget]) {
				[self makeOnMapTargetHandler:actionInvoker withParameters:@[tech, parameters]];
			} else {
				[(id)parameters insertObject:target atIndex:0];
				[self makeProviderHandler:actionInvoker withParameters:parameters];
			}
		}

		[bg setTapBeginCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
			sender.color = [UIColor greenColor];
			sender.colorBlendFactor = 0.3f;
			CGPoint anchor = sender.parent.position;
			BOOL sameAction = actionPopupNode.userData[@0] == techName;
			if (sameAction) {
				[self toggleTechSummary:actionInvoker anchoredAt:anchor];
			} else
				[self showTechSummary:actionInvoker anchoredAt:anchor];

			actionPopupNode.userData = [@{@0: techName} mutableCopy];
		}];
		[bg setTapEndCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
			sender.colorBlendFactor = 0.f;
		}];
	}

	return node;
}

- (void) updateActions:(NSArray *)selection inViewWithSize:(CGSize)viewSize {
	[self clearActions];
	int row = 0;
	AZRObject *selected = selection[0];

	float anchorHorisontal = viewSize.width - actionButtonSize.width / 2.f - GUI_MARGIN;
	float anchorVertical = actionButtonSize.height / 2.f + GUI_MARGIN;
	CGPoint pos = CGPointMake(anchorHorisontal, anchorVertical);
	for (AZRObjectProperty *p in [selected.properties allValues]) {
		if (!(TEST_BIT(p.type, AZRPropertyTypeAction) && TEST_BIT(p.type, AZRPropertyTypePublic)))
			continue;

		SKNode *actionButton = [self actionNodeProvidedBy:selected withParameters:p.vectorValue];
		actionButton.position = pos;
    [actionsNode addChild:actionButton];

		if (++row >= ACTIONS_IN_COLLUMN) {
			pos.x -= actionButtonSize.width;
			pos.y = anchorVertical;
			row = 0;
		} else
			pos.y += actionButtonSize.height;
	}
}

- (void) updateActionsProgressInViewWithSize:(CGSize)viewSize {
	for (SKNode *actionNode in [actionsNode children]) {
    AZRTechnology *tech = actionNode.userData[@(ACTION_TECH)];
		if (tech) {
			[self showTech:tech progressInNode:actionNode];
		}
	}
}

- (void) showTech:(AZRTechnology *)tech progressInNode:(SKNode *)node {
	SKNode *progressNode = [node childNodeWithName:@"progress"];
	if (![tech isInProcess]) {
		if (progressNode) {
			[progressNode removeFromParent];
		}
	} else {
		float margins = 8.f / actionProgress.size.height; // top/bottom margins
		float progress = (1.f - margins) * [tech iterationProgress] / 100.f;
		CGRect fgRect = CGRectMake(0.5f, margins / 2.f, 0.5f, progress);
		SKTexture *fgTex = [SKTexture textureWithRect:fgRect inTexture:actionProgress];
		if (!progressNode) {
			progressNode = [SKNode node];
			progressNode.name = @"progress";
			progressNode.position = CGPointMake(- (actionButtonSize.width ) / 2.f, 0);
			[node addChild:progressNode];

			CGRect bgRect = CGRectMake(0.f, 0.f, 0.5f, 1.f);
			SKTexture *bgTex = [SKTexture textureWithRect:bgRect inTexture:actionProgress];
			SKSpriteNode *barBg = [SKSpriteNode spriteNodeWithTexture:bgTex];
			SKSpriteNode *barFg = [SKSpriteNode spriteNodeWithTexture:bgTex];
			[barBg addChild:barFg];
			[progressNode addChild:barBg];
			barBg.name = @"bg";
			barFg.name = @"fg";
			barFg.anchorPoint = CGPointMake(0.5f, 0);
			[progressNode setXScale:0.8];
			[progressNode setUserInteractionEnabled:NO];
		}

		SKSpriteNode *barFG = [progressNode childNodeWithName:@"bg"].children[0];
		[barFG setYScale:progress];
		barFG.position = CGPointMake(0, - (actionProgress.size.height - 8.f) / 2.f);
		barFG.texture = fgTex;

		SKShapeNode *iterationsNode = (id)[progressNode childNodeWithName:@"iterations"];
		int iterations = [[tech iterations] count];
		if (iterations > 0) {
			if (!iterationsNode) {
				iterationsNode = [iterationsCountBGShape copy];
				[progressNode addChild:iterationsNode];
			}
			SKLabelNode *label = (id)[iterationsNode childNodeWithName:@"count"];
			label.text = [NSString stringWithFormat:@"x%i", iterations];
		} else
			[iterationsNode removeFromParent];
	}
}

#pragma mark - Action invocation

- (BOOL) showAvailability:(AZRTechnology *)tech onIcon:(SKSpriteNode *)icon {
	BOOL unavailable = [tech isUnavailable];
	icon.color = unavailable ? [UIColor redColor] : [UIColor whiteColor];
	icon.colorBlendFactor = unavailable ? 1.f : 0.f;
	return !unavailable;
}

- (void) makeOnMapTargetHandler:(AZRTappableSpriteNode *)actionNode withParameters:(NSArray *)parameters {
	NSAssert(self.delegate, @"Action delegate in GUIActionsRenderer not set!");

	AZRTechnology *tech = parameters[0];
	SKSpriteNode *icon = (SKSpriteNode *)[actionNode childNodeWithName:actionPopupIconNodeUID];
	[actionNode setTapBeginCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		if (![self showAvailability:tech onIcon:icon])
			return;

		sender.colorBlendFactor = 0.f;
		actionPopupNode.alpha = 0.6f;
		[icon setScale:1.f];
		sender.userData = [NSMutableDictionary dictionary];
		sender.userData[@"drag-begined"] = @NO;
	}];
	[actionNode setMoveCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		if (![self showAvailability:tech onIcon:icon])
			return;

		sender.userData[@"drag-begined"] = @YES;

		UITouch *touch = [touches anyObject];
		CGPoint offset = [touch locationInNode:sender];

		CGPoint mapXY;
		BOOL hitTest = [self.delegate onBuildPlaceHitTest:touch mapXY:&mapXY constrainedXY:&offset];

		icon.color = hitTest ? [UIColor whiteColor] : [UIColor redColor];
		icon.colorBlendFactor = 1.f;

		icon.position = offset;
	}];
	[actionNode setTapEndCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		if (![self showAvailability:tech onIcon:icon])
			return;

		icon.position = CGPointZero;
		float iconScale = scaleToFit(icon.size, actionButtonSize, 0.8);
		[icon setScale:iconScale];
		icon.colorBlendFactor = 0.f;
		actionPopupNode.alpha = 1.0f;

		NSNumber *dragged = sender.userData[@"drag-begined"];
		if (![dragged isEqual:@(YES)])
			return;

		UITouch *touch = [touches anyObject];
		CGPoint offset = [touch locationInNode:sender];


		CGPoint mapXY;
		if ([self.delegate onBuildPlaceHitTest:touch mapXY:&mapXY constrainedXY:&offset]) {
			AZRObject *spawnPoint = [[self.game realm] spawnObject:@"spawn-point" atX:mapXY.x andY:mapXY.y];
			BOOL queued = [[self humanPlayerTechTree] implement:YES tech:tech.name withTarget:spawnPoint];
			if (!queued) {
				spawnPoint->alive = NO;
			} else {
				[self showTech:tech progressInNode:sender.userData[@(INVOKER_ACTION_NODE)]];
			}
		}
	}];

}

- (void) makeProviderHandler:(AZRTappableSpriteNode *)actionNode withParameters:(NSArray *)parameters {
	[actionNode setTapBeginCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		SKSpriteNode *icon = (SKSpriteNode *)[sender childNodeWithName:actionPopupIconNodeUID];
		[icon setScale:1.f];
	}];
	[actionNode setTapEndCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		SKSpriteNode *icon = (SKSpriteNode *)[sender childNodeWithName:actionPopupIconNodeUID];
		[icon setScale:scaleToFit(icon.size, actionButtonSize, 0.8)];

		//TODO:provider action implementation
		NSLog(@"Implement action %@", parameters);
	}];
}

@end

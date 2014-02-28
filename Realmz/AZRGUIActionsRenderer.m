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
#import "AZRObject.h"
#import "AZRMapCommons.h"
#import "AZRRealm.h"
#import "AZRSpriteHelper.h"

@implementation AZRGUIActionsRenderer

- (id)init {
	if (!(self = [super init]))
		return self;

	actionsNode = [SKNode node];
	actionsNode.zPosition = ZINDEX_GUICOMMON;
	actionBg = [AZRSpriteHelper textureNamed:@"action-bg" fromAtlas:@"gui"];
	unknownActionIcon = [AZRSpriteHelper textureNamed:@"button-disabled" fromAtlas:@"gui"];
	actionButtonSize = actionBg.size;
	actionButtonSize.width += ACTIONS_OUTSET;
	actionButtonSize.height += ACTIONS_OUTSET;
	[self addChild:actionsNode];


	[self initActionPopup];
	[self addChild:actionPopupNode];

	return self;
}

- (SKTexture *) findActionAsociatedIcon:(NSString *)action withAnchors:(CGPoint *)anchors {
	*anchors = CGPointMake(0.5f, 0.5f);
	SKTexture *actionIcon = unknownActionIcon;
	NSString *textureName = [NSString stringWithFormat:@"%@.png", action];
	for (NSString *atlas in @[@"actions", @"buildings", @"gui"]) {
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
	float popupX = anchor.x - popupSize.width / 2.f - actionButtonSize.width / 2.f;
	float anchorY = anchor.y;
	float popupY = MAX(GUI_MARGIN, anchor.y - popupSize.height / 2.f) + popupSize.height / 2.f;
	float delta = anchorY - popupY;
	SKNode *anchorNode = [actionPopupNode childNodeWithName:actionPopupAnchorNodeUID];
	anchorNode.position = CGPointMake(anchorNode.position.x, delta);
	actionPopupNode.position = CGPointMake((int)popupX, (int)popupY);
	actionPopupNode.hidden = NO;
}

- (void) initActionPopup {
	actionPopupNode = [SKSpriteNode spriteNodeWithTexture:[AZRSpriteHelper textureNamed:@"action-popup" fromAtlas:@"gui"]];
	actionPopupNode.zPosition = ZINDEX_GUITOPLAYER;

	actionPopupNode.hidden = YES;
	CGSize popupSize = actionPopupNode.frame.size;

	SKNode *anchor = [SKSpriteNode spriteNodeWithTexture:[AZRSpriteHelper textureNamed:@"action-popup-anchor" fromAtlas:@"gui"]];
	anchor.name = actionPopupAnchorNodeUID;
	anchor.position = CGPointMake(popupSize.width / 2.f - 2.5f, 0);
	[actionPopupNode addChild:anchor];

	SKNode *contents = [SKNode node];
	contents.name = actionPopupContentsNodeUID;
	[actionPopupNode addChild:contents];
}

- (void) hideActionSummary {
	actionPopupNode.hidden = YES;
	actionPopupNode.position = CGPointMake(-1000, -1000);
}

- (void) showActionSummary:(NSString *)iconName withParameters:(NSArray *)parameters anchoredAt:(CGPoint)anchor {
	SKNode *contents = [actionPopupNode childNodeWithName:actionPopupContentsNodeUID];
	[contents removeAllChildren];

	AZRTappableSpriteNode *actionNode = [AZRTappableSpriteNode spriteNodeWithImageNamed:@"button-normal"];
	CGPoint iconAnchor = CGPointZero;
	SKSpriteNode *actionIcon = [SKSpriteNode spriteNodeWithTexture:[self findActionAsociatedIcon:iconName withAnchors:&iconAnchor]];
	actionIcon.name = actionPopupIconNodeUID;
	actionIcon.anchorPoint = iconAnchor;
	float iconScale = scaleToFit(actionIcon.size, actionNode.size, 0.8);
	[actionIcon setScale:iconScale];
	[actionNode addChild:actionIcon];

	CGSize size = actionPopupNode.frame.size;
	size.width *= 0.8;
	size.height *= 0.8;

	actionNode.position = CGPointMake((size.width - actionButtonSize.width) / 2.f, (size.height - actionButtonSize.height) / 2.f);

	NSString *actionName = parameters[0];
	parameters = [parameters subarrayWithRange:NSMakeRange(1, [parameters count] - 1)];
	if ([actionName isEqualToString:@"build"]) {
		[self makeBuildNode:actionNode withParameters:parameters];
	}
	[contents addChild:actionNode];

	[self placePopup:anchor];
}

#pragma mark Action nodes

- (void) clearActions {
  [actionsNode removeAllChildren];
	[self hideActionSummary];
}

- (SKNode *) actionNode:(NSString *)iconName withParameters:(NSArray *)parameters {
	SKNode *node = [SKNode node];
	AZRTappableSpriteNode *bg = [AZRTappableSpriteNode spriteNodeWithTexture:actionBg];
	CGPoint iconAnchor = CGPointZero;
	SKTexture *actionIcon = [self findActionAsociatedIcon:iconName withAnchors:&iconAnchor];
	SKSpriteNode *icon = [SKSpriteNode spriteNodeWithTexture:actionIcon];
	[icon setScale:scaleToFit(actionIcon.size, actionButtonSize, 0.8f)];
	[node addChild:bg];
	[bg addChild:icon];
	[bg setTapBeginCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		sender.color = [UIColor greenColor];
		sender.colorBlendFactor = 0.3f;
		CGPoint anchor = sender.parent.position;
		[self showActionSummary:iconName withParameters:parameters anchoredAt:anchor];
	}];
	[bg setTapEndCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		sender.colorBlendFactor = 0.f;
	}];
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

		if (++row > ACTIONS_IN_COLLUMN) {
			pos.x -= actionButtonSize.width;
			pos.y = anchorVertical;
			row = 0;
		}
		NSString *iconName = p.vectorValue ? p.vectorValue[0] : p.name;
		NSMutableArray *parameters = [p.vectorValue mutableCopy];
		[parameters removeObjectAtIndex:0];
		SKNode *actionButton = [self actionNode:iconName withParameters:parameters];
		actionButton.position = pos;
		pos.y += actionButtonSize.height;
    [actionsNode addChild:actionButton];
	}
}

#pragma mark - Action invocation

- (void) makeBuildNode:(AZRTappableSpriteNode *)actionNode withParameters:(NSArray *)parameters {
	[actionNode setTapBeginCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		sender.color = [UIColor lightGrayColor];
		sender.colorBlendFactor = 1.f;
		actionPopupNode.alpha = 0.6f;
		SKSpriteNode *icon = (SKSpriteNode *)[sender childNodeWithName:actionPopupIconNodeUID];
		[icon setScale:1.f];
		sender.userData = [NSMutableDictionary dictionary];
		sender.userData[@"drag-begined"] = @(NO);
	}];
	[actionNode setMoveCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		sender.userData[@"drag-begined"] = @(YES);
		SKSpriteNode *icon = (SKSpriteNode *)[sender childNodeWithName:actionPopupIconNodeUID];

		UITouch *touch = [touches anyObject];
		CGPoint offset = [touch locationInNode:sender];

		if (self.delegate) {
			CGPoint mapXY;
			BOOL hitTest = [self.delegate onBuildPlaceHitTest:touch mapXY:&mapXY constrainedXY:&offset];

			icon.color = hitTest ? [UIColor whiteColor] : [UIColor redColor];
			icon.colorBlendFactor = 1.f;
		}

		icon.position = offset;
	}];
	[actionNode setTapEndCallback:^(AZRTappableSpriteNode *sender, NSSet *touches, UIEvent *event) {
		sender.colorBlendFactor = 0.f;
		SKSpriteNode *icon = (SKSpriteNode *)[sender childNodeWithName:actionPopupIconNodeUID];
		icon.position = CGPointZero;
		float iconScale = scaleToFit(icon.size, actionButtonSize, 0.8);
		[icon setScale:iconScale];
		sender.colorBlendFactor = 0.f;
		icon.colorBlendFactor = 0.f;

		NSNumber *dragged = sender.userData[@"drag-begined"];
		if (![dragged isEqual:@(YES)])
			return;

		UITouch *touch = [touches anyObject];
		CGPoint offset = [touch locationInNode:sender];

		if (self.delegate) {
			CGPoint mapXY;
			if ([self.delegate onBuildPlaceHitTest:touch mapXY:&mapXY constrainedXY:&offset]) {
				[[AZRRealm realm] spawnObject:parameters[0] atX:mapXY.x andY:mapXY.y];
			}
		}

		actionPopupNode.alpha = 1.0f;
	}];

}

@end

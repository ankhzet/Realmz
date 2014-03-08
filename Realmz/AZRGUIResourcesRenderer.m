//
//  AZRGUIResourcesRenderer.m
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGUIResourcesRenderer.h"
#import "AZRGUIConstants.h"
#import "AZRSpriteHelper.h"
#import "AZRInGameResourceManager.h"

#define RESOURCE_PANEL_WIDE 66
#define RESOURCE_PANEL_SMALL 49

@interface AZRGUIResourcesRenderer () {
	SKNode *resourcesNode;
	SKTexture *resourceBGNormal, *resourceBGWide;
	NSDictionary *resWideness;
	NSMutableArray *resourcesWide, *resourcesShort;
}

@end

@implementation AZRGUIResourcesRenderer

- (id)init {
	if (!(self = [super init]))
		return self;

	resWideness =
	@{
		@(RESOURCE_PANEL_WIDE): @[@"gold"],
		};

	resourcesWide = [NSMutableArray array];
	resourcesShort = [NSMutableArray array];
	resourcesNode = [SKNode node];
	resourcesNode.zPosition = ZINDEX_GUICOMMON;

	resourceBGNormal = [AZRSpriteHelper textureNamed:@"resources-pane-small" fromAtlas:@"gui"];
	resourceBGWide = [AZRSpriteHelper textureNamed:@"resource-pane-big" fromAtlas:@"gui"];

	[self addChild:resourcesNode];

	return self;
}

- (NSString *) formattedResourceAmount:(AZRInGameResource *)resource {
	return [NSString stringWithFormat:@"%u", [resource amount]];
}

- (void) buildNodesTree:(AZRInGameResourceManager *)resourceManager viewSize:(CGSize)viewSize {
	[resourcesWide removeAllObjects];
	[resourcesShort removeAllObjects];
	for (NSString *resourceName in [resourceManager registeredResources]) {
    AZRInGameResource *resource = [resourceManager resourceNamed:resourceName];
		BOOL isInWideGroup = [resWideness[@(RESOURCE_PANEL_WIDE)] containsObject:resourceName];
		[(isInWideGroup ? resourcesWide : resourcesShort) addObject:resource];
	}
	[resourcesWide sortUsingComparator:^NSComparisonResult(AZRInGameResource *r1, AZRInGameResource *r2) {
		return [r1.name compare:r2.name];
	}];
	[resourcesShort sortUsingComparator:^NSComparisonResult(AZRInGameResource *r1, AZRInGameResource *r2) {
		return [r1.name compare:r2.name];
	}];

	CGPoint pos = CGPointMake(GUI_MARGIN, viewSize.height - GUI_MARGIN * 2);
	for (AZRInGameResource *resource in [resourcesWide arrayByAddingObjectsFromArray:resourcesShort]) {
		BOOL isWide = [resourcesWide containsObject:resource];
		CGFloat wide = (isWide ? RESOURCE_PANEL_WIDE : RESOURCE_PANEL_SMALL);
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:(isWide ? resourceBGWide : resourceBGNormal)];
		node.name = resource.name;
		SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"system"];
		label.text = [self formattedResourceAmount:resource];
		label.position = CGPointMake(0, 5.f);
		label.fontColor = [UIColor brownColor];
		label.fontSize = 14.f;
		label.name = @"label";

		SKSpriteNode *iconNode = [SKSpriteNode spriteNodeWithTexture:[AZRSpriteHelper textureNamed:resource.name fromAtlas:@"resources"]];
		[iconNode setScale:scaleToFit(iconNode.size, node.size, 0.35)];
		iconNode.position = CGPointMake(0, (int)(isWide ? RESOURCE_PANEL_WIDE * 2/3 : RESOURCE_PANEL_SMALL * 6/7));
		[node addChild:iconNode];

		[node addChild:label];
		node.anchorPoint = CGPointMake(0.5f, 0);
		node.position = CGPointMake((int)(pos.x + wide / 2.f), (int)(pos.y - RESOURCE_PANEL_WIDE));
		pos.x += GUI_MARGIN + wide;
		[resourcesNode addChild:node];
	}
}

- (void) updateResources:(AZRInGameResourceManager *)resourceManager viewSize:(CGSize)viewSize {
	if (![[resourcesNode children] count]) {
		[self buildNodesTree:resourceManager viewSize:viewSize];
	}

	for (NSString *resourceName in [resourceManager registeredResources]) {
    SKNode *resourceNode = [resourcesNode childNodeWithName:resourceName];
		SKLabelNode *label = (id)[resourceNode childNodeWithName:@"label"];
		AZRInGameResource *resource = [resourceManager resourceNamed:resourceName];
		label.text = [self formattedResourceAmount:resource];
	}
}

@end

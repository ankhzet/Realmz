//
//  AZRSpriteHelper.m
//  Realmz
//
//  Created by Ankh on 28.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRSpriteHelper.h"
#import <SpriteKit/SpriteKit.h>

static const CGPoint DEFAULT_ANCHOR = {0.5f, 0.5f};

@interface AZRSpriteHelper () {
	NSMutableDictionary *atlases;
	NSMutableDictionary *anchors;

}
@end
@implementation AZRSpriteHelper

+ (AZRSpriteHelper *) helper {
	static AZRSpriteHelper *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
    instance = [[self alloc] initSingletone];
	});
	return instance;
}

- (id)init {
	@throw [NSException exceptionWithName:@"AZRSpriteHelperInit" reason:@"AZRSpriteHelper should be initialized as singletone" userInfo:nil];
}

- (id)initSingletone {
	if (!(self = [super init]))
		return self;

	atlases = [NSMutableDictionary dictionary];

	NSString *anchorsFile = [[NSBundle mainBundle] pathForResource:@"anchors" ofType:@"plist"];
	anchors = [NSMutableDictionary dictionaryWithContentsOfFile:anchorsFile];

	return self;
}

+ (id) textureNamed:(NSString *)textureName fromAtlasNoPlaceholder:(NSString *)atlasName {
	SKTextureAtlas *atlas = [self helper]->atlases[atlasName];
	if (!atlas) {
		atlas = [SKTextureAtlas atlasNamed:atlasName];
		[self helper]->atlases[atlasName] = atlas;
	}
	return [[atlas textureNames] containsObject:textureName] ? [atlas textureNamed:textureName] : nil;
}

+ (id) textureNamed:(NSString *)textureName fromAtlas:(NSString *)atlasName {
	SKTextureAtlas *atlas = [self helper]->atlases[atlasName];
	if (!atlas) {
		atlas = [SKTextureAtlas atlasNamed:atlasName];
		[self helper]->atlases[atlasName] = atlas;
	}
	return [atlas textureNamed:textureName];
}

+ (CGPoint) getAnchorForTexture:(NSString *)textureName inAtlas:(NSString *)atlas {
	NSString *anchor = [self helper]->anchors[atlas][textureName];
	if (!anchor) {
		return DEFAULT_ANCHOR;
	}

	NSArray *coord = [anchor componentsSeparatedByString:@":"];
	int cx = [coord[0] integerValue];
	int cy = [coord[1] integerValue];
	SKTexture *texture = [self textureNamed:textureName fromAtlas:atlas];
	float dx = cx / texture.size.width;
	float dy = cy / texture.size.height;
	return CGPointMake(dx, dy);
}

@end

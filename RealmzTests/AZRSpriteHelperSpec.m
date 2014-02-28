//
//  AZRSpriteHelperSpec.m
//  Realmz
//
//  Created by Ankh on 28.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRSpriteHelper.h"
#import <SpriteKit/SpriteKit.h>

SPEC_BEGIN(AZRSpriteHelperSpec)

describe(@"Testing AZRSpriteHelper", ^{

	it(@"should be singletone", ^{
		AZRSpriteHelper *helper = [AZRSpriteHelper helper];
		[[helper shouldNot] beNil];
		[[helper should] beKindOfClass:[AZRSpriteHelper class]];
		[[helper should] beIdenticalTo:[AZRSpriteHelper helper]];
	});

	it(@"should load textures from atlases", ^{
		SKTexture *tex1 = [AZRSpriteHelper textureNamed:@"pavilion" fromAtlas:@"buildings"];
		[[tex1 shouldNot] beNil];
		SKTexture *tex2 = [AZRSpriteHelper textureNamed:@"pavilion" fromAtlasNoPlaceholder:@"trees"];
		[[tex2 should] beNil];
	});

	it(@"should aquire anchor info", ^{
		CGPoint anchor = [AZRSpriteHelper getAnchorForTexture:@"pavilion" inAtlas:@"buildings"];
		[[theValue(anchor) shouldNot] equal:theValue(CGPointMake(0.5f, 0.5f))];
	});
});

SPEC_END

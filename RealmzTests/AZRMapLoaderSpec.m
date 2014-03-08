//
//  AZRMapLoaderSpec.m
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRMapLoader.h"
#import "AZRMap.h"
#import "AZRMapLayer.h"
#import "AZRMapLayerCellShortcut.h"

SPEC_BEGIN(AZRMapLoaderSpec)

describe(@"Testing map loader", ^{

	it(@"should properly initialize", ^{
		AZRMapLoader *loader = [AZRMapLoader new];
		[[loader shouldNot] beNil];
		[[[loader resourceType] should] equal:AZRUnifiedFileTypeMap];
		[[[loader grammar] should] equal:@"map"];
	});

	it(@"should load map", ^{
		AZRMapLoader *loader = [AZRMapLoader new];

		NSString *mapTestSource = @"\
		map 'test-map' {\
		author 'Ankh';\
		version '1.0';\
		description 'Some description';\
		}\
		";
		AZRMap *map = [loader loadFromString:mapTestSource];
		[[map shouldNot] beNil];
		[[map should] beKindOfClass:[AZRMap class]];

		[[[map name] should] equal:@"test-map"];
		[[[map author] should] equal:@"Ankh"];
		[[[map version] should] equal:@"1.0"];
		[[[map summary] should] equal:@"Some description"];
	});

	it(@"should parse map global-scripts", ^{
		AZRMapLoader *loader = [AZRMapLoader new];

		NSString *mapTestSource = @"\
		map 'test-map' {\
		global-scripts ['script1', 'script2'];\
		}\
		";

		AZRMap *map = [loader loadFromString:mapTestSource];
		[[map shouldNot] beNil];

		[[map.globalScripts shouldNot] beNil];
		[[theValue([map.globalScripts count]) should] equal:@(2)];

		[[map.globalScripts[0] should] equal:@"script1"];
		[[map.globalScripts[1] should] equal:@"script2"];
	});

	it(@"should load layers", ^{
		AZRMapLoader *loader = [AZRMapLoader new];

		NSString *mapTestSource = @"\
		map 'test-map' {\
		layers {\
		layer 'layer-1-name' {\
		}\
		layer 'layer-2-name' {\
			tiled;\
		}\
		}\
		}\
		";

		AZRMap *map = [loader loadFromString:mapTestSource];
		[[map shouldNot] beNil];

		[[map.layers shouldNot] beNil];
		[[theValue([map.layers count]) should] equal:@(2)];
		[[[map.layers allKeys] should] contain:@"layer-1-name"];
		[[[map.layers allKeys] should] contain:@"layer-2-name"];

		AZRMapLayer *layer0 = map.layers[@"layer-1-name"];
		AZRMapLayer *layer1 = [map addNewLayerNamed:@"layer-1-name"];
		AZRMapLayer *layer2 = [map addNewLayerNamed:@"layer-2-name"];

		[[layer1 should] beIdenticalTo:layer0];

		[[layer1 should] beKindOfClass:[AZRMapLayer class]];
		[[theValue(layer1.tiled) should] beNo];
		[[layer2 should] beKindOfClass:[AZRMapLayer class]];
		[[theValue(layer2.tiled) should] beYes];
	});

	it(@"should parse layer shortcuts", ^{
		AZRMapLoader *loader = [AZRMapLoader new];

		NSString *mapTestSource = @"\
		map 'test-map' {\
		layers {\
		layer 'test-layer' {\
		shortcut 1 'short1';\
		tiled;\
		shortcut 2 'short2' [['param1', 'value1'], ['param2', 'value2']];\
		shortcut 3 'short3';\
		}\
		}\
		}\
		";

		AZRMap *map = [loader loadFromString:mapTestSource];
		[[map shouldNot] beNil];

		[[map.layers shouldNot] beNil];
		[[theValue([map.layers count]) should] equal:@(1)];
		[[[map.layers allKeys] should] contain:@"test-layer"];

		AZRMapLayer *layer = [map addNewLayerNamed:@"test-layer"];

		[[layer should] beKindOfClass:[AZRMapLayer class]];
		[[theValue(layer.tiled) should] beYes];

		[[layer.shortcuts shouldNot] beNil];
		[[layer.shortcuts shouldNot] beEmpty];

		AZRMapLayerCellShortcut *shortcut2 = layer.shortcuts[@(2)];
		[[shortcut2 shouldNot] beNil];
		[[shortcut2.identifier should] equal:@"short2"];
		[[shortcut2.parameters shouldNot] beNil];
		[[shortcut2.parameters should] haveCountOf:2];

		AZRMapLayerCellShortcut *shortcut3 = layer.shortcuts[@(3)];
		[[shortcut3 shouldNot] beNil];
		[[shortcut3.identifier should] equal:@"short3"];

		AZRMapLayerCellShortcut *shortcut4 = layer.shortcuts[@(4)];
		[[shortcut4 should] beNil];
	});

	it(@"should parse layer grid-data", ^{
		AZRMapLoader *loader = [AZRMapLoader new];

		NSString *mapTestSource = @"\
		map 'test-map' {\
		layers {\
		layer 'test-layer' {\
		grid-data [\
		'5001000',\
		'0402000',\
		'0003000',\
		'0004020',\
		'0005001'\
		];\
		}\
		}\
		}\
		";

		AZRMap *map = [loader loadFromString:mapTestSource];
		[[map shouldNot] beNil];

		AZRMapLayer *layer = [map addNewLayerNamed:@"test-layer"];
		[[layer shouldNot] beNil];

		// should add '0' at end to make map width multiple of 2
		[[[layer gridRow:-3] should] equal:@"0500100000"];
		[[[layer gridRow:-2] should] equal:@"0040200000"];
		[[[layer gridRow:-1] should] equal:@"0000300000"];
		[[[layer gridRow: 0] should] equal:@"0000402000"];
		[[[layer gridRow: 1] should] equal:@"0000500100"];
		[[[layer gridRow: 2] should] equal:@"0000000000"];

		[[@([layer gridCellAtXY:AZRIntPointMake(-3, -2)]) should] equal:@(4)];
		[[@([layer gridCellAtXY:AZRIntPointMake(1, 0)]) should] equal:@(2)];
		[[@([layer gridCellAtXY:AZRIntPointMake(2, 0)]) should] equal:@(0)];
	});

	it(@"should parse layer object-data", ^{
		AZRMapLoader *loader = [AZRMapLoader new];

		NSString *mapTestSource = @"\
		map 'test-map' {\
		layers {\
		layer 'test-layer' {\
		object-data {\
		1 [\
		[10, 10],\
		[1, -5],\
		[-12, 22]\
		];\
		2 [\
		[15, 5],\
		[-7, -3]\
		];\
		5 [\
		[-5, -5],\
		[5, -5],\
		[5, 5],\
		[-5, 5]\
		];\
		}\
		}\
		}\
		}\
		";

		AZRMap *map = [loader loadFromString:mapTestSource];
		[[map shouldNot] beNil];

		AZRMapLayer *layer = [map addNewLayerNamed:@"test-layer"];
		[[layer shouldNot] beNil];

		[[@([layer gridCellAtXY:AZRIntPointMake(10, 10)]) should] equal:@(1)];
		[[@([layer gridCellAtXY:AZRIntPointMake(1, -5)]) should] equal:@(1)];
		[[@([layer gridCellAtXY:AZRIntPointMake(-12, 22)]) should] equal:@(1)];

		[[@([layer gridCellAtXY:AZRIntPointMake(15, 5)]) should] equal:@(2)];
		[[@([layer gridCellAtXY:AZRIntPointMake(-7, -3)]) should] equal:@(2)];

		[[@([layer gridCellAtXY:AZRIntPointMake(-5, -5)]) should] equal:@(5)];
		[[@([layer gridCellAtXY:AZRIntPointMake(5, -5)]) should] equal:@(5)];
		[[@([layer gridCellAtXY:AZRIntPointMake(5, 5)]) should] equal:@(5)];
		[[@([layer gridCellAtXY:AZRIntPointMake(-5, 5)]) should] equal:@(5)];

	});
});

SPEC_END

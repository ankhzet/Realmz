//
//  AZRMapBuilder.m
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMapLoader.h"
#import "AZRMap.h"
#import "AZRMapLayer.h"
#import "AZRMapLayerCellShortcut.h"

#define _LOG_ASSEMBLY 0

#if _LOG_ASSEMBLY
#define LOG_ASSEMBLY() NSLog(@"\n\n%s\n%@\n\n", __PRETTY_FUNCTION__, a);
#else
#define LOG_ASSEMBLY()

#endif

AZRUnifiedFileType const AZRUnifiedFileTypeMap = @"map";

@implementation AZRMapLoader

#pragma mark - Common loader overrides

-(AZRUnifiedFileType) resourceType {
	return AZRUnifiedFileTypeMap;
}

-(NSString *)grammar {
	return @"map";
}

#pragma mark - Parser implementation

- (void)parser:(PKParser *)parser didMatchMap:(PKAssembly *)a {
	LOG_ASSEMBLY()
	AZRMap *map = [a pop];
	[a push:map];
	LOG_ASSEMBLY()
}

- (void)parser:(PKParser *)parser didMatchMapKeyword:(PKAssembly *)a {
	[a push:[AZRMap new]];
}

- (void)parser:(PKParser *)parser didMatchMapName:(PKAssembly *)a {
	NSString *name = [a pop];
	AZRMap *map = [a pop];
	[map setName:name];
	[a push:map];
}

#pragma mark Global scripts

- (void)parser:(PKParser *)parser didMatchGlobalScripts:(PKAssembly *)a {
	NSArray *vector = [a pop];
	AZRMap *map = [a pop];
	[map setGlobalScripts:vector];
	[a push:map];
}

#pragma mark Layers

- (void)parser:(PKParser *)parser didMatchLayers:(PKAssembly *)a {
	NSMutableArray *layers = [NSMutableArray array];
	id top;
	while ((top = [a pop]) && [top isKindOfClass:[AZRMapLayer class]])
		[layers insertObject:top atIndex:0];

	NSAssert([top isKindOfClass:[AZRMap class]], @"[AZRMap] object expected, [%@] found", NSStringFromClass([top class]));

	AZRMap *map = top;
	for (AZRMapLayer *layer in layers) {
    [map addLayer:layer];
	}
	[a push:map];
}

- (void)parser:(PKParser *)parser didMatchLayerDefine:(PKAssembly *)a {
	NSString *layedIdentifier = [a pop];
	AZRMapLayer *layer = [AZRMapLayer new];
	[layer setName:layedIdentifier];
	[a push:layer];
}

#pragma mark Layer elements

- (void)parser:(PKParser *)parser didMatchTiledKeyword:(PKAssembly *)a {
	AZRMapLayer *layer = [a pop];
	NSAssert([layer isKindOfClass:[AZRMapLayer class]], @"[AZRMapLayer] object expected, [%@] found", NSStringFromClass([layer class]));

	[layer setTiled:YES];
	[a push:layer];
}

#pragma mark Layer shortcuts

- (void)parser:(PKParser *)parser didMatchShortcut:(PKAssembly *)a {
	LOG_ASSEMBLY()
	NSArray *parameters = nil;
	id top = [a pop];
	NSString *identifier = top;
	if ([top isKindOfClass:[NSArray class]]) {
		parameters = top;
		identifier = [a pop];
	}
	NSUInteger uid = [[a pop] integerValue];
	AZRMapLayer *layer = [a pop];
	AZRMapLayerCellShortcut *shortcut = [layer addShortcut:uid forIdentifier:identifier];;
	[shortcut setParameters:parameters];
	[a push:layer];
	LOG_ASSEMBLY()
}

#pragma mark Layer data: grid data

- (void)parser:(PKParser *)parser didMatchGridData:(PKAssembly *)a {
	NSArray *srcData = [a pop];
	// transform to uppercase
	NSMutableArray *data = [NSMutableArray array];
	for (NSString *row in srcData) {
    [data addObject:[row uppercaseString]];
	}
	AZRMapLayer *layer = [a pop];
	[layer setGridData:data];
	[a push:layer];
}

#pragma mark Layer data: object data

- (void)parser:(PKParser *)parser didMatchObjectSpawn:(PKAssembly *)a {
	NSArray *coordinates = [a pop];
	NSUInteger objUID = [[a pop] integerValue];
	AZRMapLayer *layer = [a pop];

	for (NSArray *coordinate in coordinates) {
    [layer setGridCell:objUID atXY:AZRIntPointMake([coordinate[0] intValue], [coordinate[1] intValue])];
	}

	[a push:layer];
}


@end

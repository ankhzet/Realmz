//
//  AZRMap.m
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMap.h"
#import "AZRMapCommons.h"
#import "AZRMapLayer.h"
#import "AZRMapChunk.h"

@implementation AZRMap
@synthesize width = _width;
@synthesize height = _height;
@synthesize layers = _layers;

- (id)init {
	if (!(self = [super init]))
		return self;

	_width = _height = -1;
	_layers = [NSMutableDictionary dictionary];
	return self;
}

- (AZRMapLayer *) addNewLayerNamed:(NSString *)layerIdentifier {
	AZRMapLayer *layer = _layers[layerIdentifier];
	if (!layer) {
		layer = [AZRMapLayer new];
		[layer setName:layerIdentifier];
		return [self addLayer:layer];
	}
	return layer;
}

- (AZRMapLayer *) addLayer:(AZRMapLayer *)layer {
	_layers[layer.name] = layer;
	return layer;
}

- (AZRIntPoint) centerCell {
	return AZRIntPointMake(_width / 2, _height / 2);
}

- (int) width {
	if (_width <= 0) {
		for (AZRMapLayer *layer in [_layers allValues]) {
			_width = MAX(_width, layer.width);
			_height = MAX(_height, layer.height);
		}
	}
	return _width;
}

- (int) height {
	if (_height <= 0) {
		[self width];
	}
	return _height;
}

- (void) process:(NSTimeInterval)currentTime {
	//TODO: map scripts processing
}

@end

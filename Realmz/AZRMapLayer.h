//
//  AZRMapLayer.h
//  Realmz
//
//  Created by Ankh on 25.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRMapCommons.h"
#import <SpriteKit/SpriteKit.h>

@class AZRMapLayerCellShortcut;

@interface AZRMapLayer : SKNode
@property (nonatomic) BOOL tiled;

@property (nonatomic) NSMutableDictionary *shortcuts;

@property (nonatomic) NSMutableArray *gridData;

@property (nonatomic) int width;
@property (nonatomic) int height;

- (AZRMapLayerCellShortcut *) addShortcut:(int)uid forIdentifier:(NSString *)identifier;

- (NSMutableString *) gridRow:(int)row;
- (int) gridCellAtXY:(AZRIntPoint)point;
- (void) setGridCell:(int)cell atXY:(AZRIntPoint)point;

- (BOOL) buildForTileSize:(CGSize)tileSize;

@end

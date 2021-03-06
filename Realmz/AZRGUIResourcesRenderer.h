//
//  AZRGUIResourcesRenderer.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class AZRInGameResourceManager;
@interface AZRGUIResourcesRenderer : SKNode

- (void) updateResources:(AZRInGameResourceManager *)resourceManager viewSize:(CGSize)viewSize;

@end

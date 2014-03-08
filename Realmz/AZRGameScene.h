//
//  AZRGameScene.h
//  Realmz
//
//  Created by Ankh on 05.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AZRGUIActionsRenderer.h"
#import "AZRGUIRenderer.h"

@class AZRGame, AZRGUIRenderer, AZRGameRenderer;
@interface AZRGameScene : SKScene
<AZRGUIActionsRendererDelegate, AZRGUIRendererDelegate>

@property (nonatomic) AZRGame *game;
@property (nonatomic) AZRGameRenderer *gameRenderer;
@property (nonatomic) AZRGUIRenderer *guiRenderer;

+ (instancetype) sceneForGame:(AZRGame *)game withSize:(CGSize)size;

- (void) process:(NSTimeInterval)currentTime;

@end

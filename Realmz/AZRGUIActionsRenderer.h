//
//  AZRGUIActionsRenderer.h
//  Realmz
//
//  Created by Ankh on 28.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@protocol AZRGUIActionsRendererDelegate <NSObject>

- (BOOL) onBuildPlaceHitTest:(UITouch *)hitTouch mapXY:(CGPoint *)mapXY constrainedXY:(CGPoint *)constrained;

@end

@class AZRGame;
/*!
 @brief Create all required render tree hierarchy.
 Handles actions render & actions invocation.
 Is root node for rendering.
 */
@interface AZRGUIActionsRenderer : SKNode

@property (nonatomic, weak, readonly) AZRGame *game;
@property (nonatomic) id<AZRGUIActionsRendererDelegate> delegate;

+ (instancetype) actionsRendererForGame:(AZRGame *)game;

- (void) updateActions:(NSArray *)selection inViewWithSize:(CGSize)viewSize;
- (void) updateActionsProgressInViewWithSize:(CGSize)viewSize;
- (void) clearActions;


@end

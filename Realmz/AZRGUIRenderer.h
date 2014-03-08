//
//  AZRGUIRenderer.h
//  Realmz
//
//  Created by Ankh on 25.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRGUIActionsRenderer, AZRGUIResourcesRenderer;
@class SKNode, AZRGame, AZRInGameResourceManager, AZRTappableSpriteNode;

@protocol AZRGUIRendererDelegate <NSObject>

- (CGPoint) mapScrolledTo;

- (void) guiCtlPressed:(AZRTappableSpriteNode *)ctl;
- (void) guiCtlReleased:(AZRTappableSpriteNode *)ctl;

@end

@interface AZRGUIRenderer : SKNode
@property (nonatomic, weak) AZRGame *game;
@property (nonatomic) NSMutableArray *selection;
@property (nonatomic) AZRGUIActionsRenderer *actionsRenderer;
@property (nonatomic) AZRGUIResourcesRenderer *resourcesRenderer;
@property (nonatomic) id<AZRGUIRendererDelegate> delegate;

+ (instancetype) rendererForGame:(AZRGame *)game;

- (void) update:(CGSize)viweSize forCurrentTime:(CFTimeInterval)currentTime;

- (BOOL) isSelecting;
- (void) clearSelection;

/*!
	@brief Initializes hud for object selection.
 */
- (void) beginSelection:(CGPoint)tapLocation withMapScroll:(CGPoint)scrollOffset andTileSize:(CGSize)tileSize;
/*!
 @brief Ends object selection.
 */
- (void) endSelection;
/*!
 @brief Updates selection.
 */
- (void) updateSelection:(CGPoint)tapLocation withMapScroll:(CGPoint)scrollOffset andTileSize:(CGSize)tileSize;

@end

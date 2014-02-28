//
//  AZRGUIRenderer.h
//  Realmz
//
//  Created by Ankh on 25.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKNode, AZRRealm, AZRGUIActionsRenderer, AZRTappableSpriteNode;

@protocol AZRGUIRendererDelegate <NSObject>

- (void) guiCtlPressed:(AZRTappableSpriteNode *)ctl;
- (void) guiCtlReleased:(AZRTappableSpriteNode *)ctl;

@end

@interface AZRGUIRenderer : NSObject
@property (nonatomic, weak) AZRRealm *realm;
@property (nonatomic) NSMutableArray *selection;
@property (nonatomic) SKNode *graphicsNode;
@property (nonatomic) AZRGUIActionsRenderer *actionsRenderer;
@property (nonatomic) id<AZRGUIRendererDelegate> delegate;

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

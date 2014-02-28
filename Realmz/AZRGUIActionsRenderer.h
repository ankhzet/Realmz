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

/*!
 @brief Create all required render tree hierarchy.
 Handles actions render & actions invocation.
 Is root node for rendering.
 */
@interface AZRGUIActionsRenderer : SKNode {
	SKNode *actionsNode;
	SKNode *actionPopupNode;
	CGSize actionButtonSize;
	SKTexture *actionBg;
	SKTexture *unknownActionIcon;
}

@property (nonatomic) id<AZRGUIActionsRendererDelegate> delegate;

- (void) updateActions:(NSArray *)selection inViewWithSize:(CGSize)viewSize;
- (void) clearActions;

/*!
 @brief Show action summary pop-up.
 @param iconName Name of action-icon texture, that will be used for action button.
 @param parameters Action parameters (like action name etc).
 @param anchor Coordinates of anchor point for pop-up (bottom-right corner of pop-up).
 */
- (void) showActionSummary:(NSString *)iconName withParameters:(NSArray *)parameters anchoredAt:(CGPoint)anchor;
/*!
 @brief Hide action summary pop-up.
 */
- (void) hideActionSummary;

@end

//
//  AZRTappableSpriteNode.h
//  Realmz
//
//  Created by Ankh on 27.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class AZRTappableSpriteNode;
typedef void (^AZRTappableSpriteNodeCallback)(AZRTappableSpriteNode *sender, NSSet * touches, UIEvent * event);

@interface AZRTappableSpriteNode : SKSpriteNode {
	AZRTappableSpriteNodeCallback tapBeginBlock;
	AZRTappableSpriteNodeCallback moveBlock;
	AZRTappableSpriteNodeCallback tapEndBlock;
}

- (void) setTapBeginCallback:(AZRTappableSpriteNodeCallback)block;
- (void) setTapEndCallback:(AZRTappableSpriteNodeCallback)block;
- (void) setMoveCallback:(AZRTappableSpriteNodeCallback)block;
@end
//
//  AZRTappableSpriteNode.m
//  Realmz
//
//  Created by Ankh on 27.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTappableSpriteNode.h"

@implementation AZRTappableSpriteNode

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (tapBeginBlock) {
		tapBeginBlock(self, touches, event);
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (tapEndBlock) {
		tapEndBlock(self, touches, event);
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (moveBlock) {
		moveBlock(self, touches, event);
	}
}

- (void) setTapBeginCallback:(AZRTappableSpriteNodeCallback)block {
	tapBeginBlock = block;
	[self setUserInteractionEnabled:YES];
}

- (void) setTapEndCallback:(AZRTappableSpriteNodeCallback)block {
	tapEndBlock = block;
	[self setUserInteractionEnabled:YES];
}

- (void) setMoveCallback:(AZRTappableSpriteNodeCallback)block {
	moveBlock = block;
	[self setUserInteractionEnabled:YES];
}

@end
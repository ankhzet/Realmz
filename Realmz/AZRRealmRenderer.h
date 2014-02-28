//
//  AZRRealmRenderer.h
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class AZRRealm;

@interface AZRRealmRenderer : SKScene
- (void) attachToRealm:(AZRRealm *)realm;
- (void) processed:(CFTimeInterval)currentTime;

@end

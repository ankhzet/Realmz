//
//  AZRSpriteHelper.h
//  Realmz
//
//  Created by Ankh on 28.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZRSpriteHelper : NSObject

+ (AZRSpriteHelper *) helper;

+ (id) textureNamed:(NSString *)textureName fromAtlasNoPlaceholder:(NSString *)atlasName;
+ (id) textureNamed:(NSString *)textureName fromAtlas:(NSString *)atlasName;
+ (CGPoint) getAnchorForTexture:(NSString *)textureName inAtlas:(NSString *)atlas;

@end

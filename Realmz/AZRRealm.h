//
//  AZRRealm.h
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObject;
@class AZRObjectClassDescription;

@interface AZRRealm : NSObject

- (AZRObject *) spawnObject:(AZRObjectClassDescription *)objectDescriptor;
- (AZRObject *) spawnObject:(NSString *)objectClassDescription atX:(float)x andY:(float)y;
- (NSArray *) allObjects;

- (NSArray *) inRangeOf:(CGPoint)center withDistanceOf:(float)distance;
- (NSArray *) overlapsWith:(CGPoint)center withDistanceOf:(float)distance;
- (NSArray *) inRectOf:(CGRect)rect;

- (BOOL) process;

@end

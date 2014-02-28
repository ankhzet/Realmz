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

typedef BOOL (^AZRObjectFilterBlock)(AZRObject *object, BOOL *stop);

@interface AZRRealm : NSObject

/*!
 @brief Singletone realm instance allocation.
 */
+ (AZRRealm *) realm;

- (AZRObject *) spawnObject:(AZRObjectClassDescription *)objectDescriptor;
- (AZRObject *) spawnObject:(NSString *)objectClassDescription atX:(float)x andY:(float)y;
- (NSArray *) allObjects;

/*!
 @brief Filters all objects, that accepted by block.
 @param block Block to test objects with.
 */
- (NSArray *) filterWithBlock:(AZRObjectFilterBlock)block;

/*!
 @brief Filters all objects, that have distance to specified point less or equal to specified amount.
 @param center Coordinates of test point.
 @param distance Distance to point to pass the test.
 */
- (NSArray *) inRangeOf:(CGPoint)center withDistanceOf:(float)distance;

/*!
 @brief Filters all objects, that overlaps with circular area of specified radius.
 @param center Coordinates of circular area.
 @param distance Radius of circular area.
 */
- (NSArray *) overlapsWith:(CGPoint)center withDistanceOf:(float)distance;

/*!
 @brief Filters all objects, whose pos lays in specified rect area.
 @param rect Test rectangle.
 */
- (NSArray *) inRectOf:(CGRect)rect;

- (BOOL) process;

@end

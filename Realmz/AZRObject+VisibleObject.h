//
//  AZRObject+VisibleObject.h
//  Realmz
//
//  Created by Ankh on 16.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AZRObject.h"

extern AZRObjectCommonProperty const AZRObjectCommonPropertyCoordinates;
extern AZRObjectCommonProperty const AZRObjectCommonPropertyRadius;
extern AZRObjectCommonProperty const AZRObjectCommonPropertyWeight;

extern AZRObjectCommonProperty const AZRObjectCommonPropertyMaxHealth;
extern AZRObjectCommonProperty const AZRObjectCommonPropertyHealth;

@interface AZRObject (VisibleObject)

- (CGPoint) coordinates;
- (void) moveToXY:(CGPoint)targetXY;
- (float) sqrDistanceTo:(CGPoint)point;

- (float) radius;
- (float) weight;

- (float) maxHealth;
- (float) health;

@end

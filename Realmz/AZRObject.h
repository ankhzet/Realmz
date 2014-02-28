//
//  AZRObject.h
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRObjectClassDescription.h"

@class AZRObjectAction, AZRRealm;

@interface AZRObject : NSObject {
@public
	__weak AZRRealm *realm;
	__weak id renderBody;
}

@property (nonatomic) AZRObjectClassDescription *classDescription;
@property (nonatomic) NSDictionary *properties;

- (id) initFromDescription: (AZRObjectClassDescription *) description;
- (NSString *) AZRClass;

- (AZRObjectProperty *) addProperty:(AZRObjectCommonProperty)propertyName;
- (float) floatProperty:(AZRObjectCommonProperty)propertyName;
- (float) floatPropertyIncrease:(AZRObjectCommonProperty)propertyName withValue:(float)value;

- (void) isPerforming:(AZRObjectAction *)performedAction;
- (AZRObjectAction *) performedAction;

- (NSValue *) targetedTo;
- (void) setTargetedTo:(NSValue *)coordinates;

@end

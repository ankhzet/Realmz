//
//  AZRObjectDescription
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AZRObjectProperty.h"

@class AZRObject;

@interface AZRObjectClassDescription : NSObject

@property (nonatomic, weak) AZRObjectClassDescription *parent;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *summary;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *version;
@property (nonatomic) NSDictionary *publicProperties;
@property (nonatomic) NSUInteger multiSelectionGroup;

- (id) initWithName: (NSString *) name;
- (NSString *) instanceClass;

- (BOOL) addProperty: (AZRObjectProperty *)property;
- (BOOL) addProperty: (NSString *) propertyName withType: (AZRPropertyType) type;
- (AZRObjectProperty *) hasProperty: (NSString *) property;
- (AZRObjectProperty *) hasPublicProperty: (NSString *) property;

- (AZRObject *) instantiateObject;

- (BOOL) compatibleWith: (NSSet *) descriptions;

@end

//
//  AZRObjectProperty.h
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AZRPropertyType) {
	AZRPropertyTypePublic = 1,
	AZRPropertyTypeDiscoverable = 2,
	AZRPropertyTypeProperty = 4,
	AZRPropertyTypeAction = 8
};

typedef NSString* AZRObjectCommonProperty;

@interface AZRObjectProperty : NSObject <NSCopying>

@property (nonatomic) NSString *name;

@property (nonatomic) NSNumber *numberValue;
@property (nonatomic) NSString *stringValue;
@property (nonatomic) NSArray *vectorValue;

@property (nonatomic) AZRPropertyType type;

- (id) initWithName: (NSString *) name;

@end

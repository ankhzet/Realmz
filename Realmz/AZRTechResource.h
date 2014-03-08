//
//  AZRTechResource.h
//  Realmz
//
//  Created by Ankh on 02.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AZRTechResourceType) {
	AZRTechResourceTypeResource = 1 << 0,
	AZRTechResourceTypeUnit     = 1 << 1,
	AZRTechResourceTypeTech     = 1 << 4,
};

typedef NS_ENUM(NSUInteger, AZRResourceHandler) {
	AZRResourceHandlerNormal   = 0,
	AZRResourceHandlerOnMap    = 1 << 0,
	AZRResourceHandlerProvider = 1 << 1,
};

@interface AZRTechResource : NSObject

@property (nonatomic) AZRTechResourceType type;
@property (nonatomic) AZRResourceHandler handler;
@property (nonatomic) NSString *resource;
@property (nonatomic) int amount;

+ (instancetype) resourceWithType:(AZRTechResourceType)resourceType;

@end

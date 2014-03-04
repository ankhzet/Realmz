//
//  AZRTechResource.m
//  Realmz
//
//  Created by Ankh on 02.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechResource.h"

@implementation AZRTechResource

+ (instancetype) resourceWithType:(AZRTechResourceType)resourceType {
	AZRTechResource *resource = [self new];
	resource.type = resourceType;
	return resource;
}

@end

//
//  AZRTechLoader.m
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechLoader.h"
#import "AZRTechTree.h"
#import "AZRTechnology.h"
#import "AZRTechResource.h"

#define _LOG_ASSEMBLY 1

#if _LOG_ASSEMBLY
#define LOG_ASSEMBLY() NSLog(@"\n\n%s\n%@\n\n", __PRETTY_FUNCTION__, a);
#else
#define LOG_ASSEMBLY()

#endif

AZRUnifiedFileType const AZRUnifiedFileTypeTechnology = @"tech";

@implementation AZRTechLoader

#pragma mark - Common loader overrides

-(AZRUnifiedFileType) resourceType {
	return AZRUnifiedFileTypeTechnology;
}

-(NSString *)grammar {
	return @"tech";
}

#pragma mark - Parser implementation

- (void)parser:(PKParser *)parser didMatchTech:(PKAssembly *)a {
	LOG_ASSEMBLY()
	AZRTechnology *tech = [a pop];
	[a push:tech];
	LOG_ASSEMBLY()
}

- (void)parser:(PKParser *)parser didMatchTechName:(PKAssembly *)a {
	NSString *name = [a pop];
	[a push:[[AZRTechnology alloc] initWithName:name]];
}

#pragma mark - Tech atributes

- (void)parser:(PKParser *)parser didMatchMultiple:(PKAssembly *)a {
	NSNumber *value = [a pop];
	AZRTechnology *tech = [a pop];
	tech.multiple = [value integerValue];
	[a push:tech];
}

- (void)parser:(PKParser *)parser didMatchImplementFor:(PKAssembly *)a {
	NSNumber *value = [a pop];
	AZRTechnology *tech = [a pop];
	tech.iterationTime = [value floatValue];
	[a push:tech];
}

- (void)parser:(PKParser *)parser didMatchFinal:(PKAssembly *)a {
	AZRTechnology *tech = [a pop];
	tech.final = YES;
	[a push:tech];
}

#pragma mark - Drains & gains

- (void)parser:(PKParser *)parser didMatchDrains:(PKAssembly *)a {
	LOG_ASSEMBLY()
	NSArray *array = [a pop];
	if ([array isKindOfClass:[NSArray class]]) {
		AZRTechnology *tech = [a pop];
		for (AZRTechResource *techResource in array) {
			AZRTechResource *copy = [tech addDrain:techResource.type];
			copy.resource = techResource.resource;
			copy.handler = techResource.handler;
			copy.amount = techResource.amount;
		}
		[a push:tech];
	} else
		[a push:array];
	LOG_ASSEMBLY()
}

- (void)parser:(PKParser *)parser didMatchGains:(PKAssembly *)a {
	LOG_ASSEMBLY()
	NSArray *array = [a pop];
	if ([array isKindOfClass:[NSArray class]]) {
		AZRTechnology *tech = [a pop];
		for (AZRTechResource *techResource in array) {
			AZRTechResource *copy = [tech addGain:techResource.type];
			copy.resource = techResource.resource;
			copy.handler = techResource.handler;
			copy.amount = techResource.amount;
		}
		[a push:tech];
	} else
		[a push:array];
	LOG_ASSEMBLY()
}

#pragma mark - Resources

- (void)parser:(PKParser *)parser didMatchResources:(PKAssembly *)a {
	LOG_ASSEMBLY()
	NSMutableArray *array = [NSMutableArray array];
	id resource;
	while ([(resource = [a pop]) isKindOfClass:[AZRTechResource class]]) {
		[array addObject:resource];
	}

	AZRTechnology *tech = resource;
	NSAssert([tech isKindOfClass:[AZRTechnology class]], @"Expected for [AZRTechnology] object, but [%@] found", NSStringFromClass([tech class]));
	[a push:tech];

	[a push:array];
	LOG_ASSEMBLY()
}

#pragma mark Resource types

- (void)parser:(PKParser *)parser didMatchResourceType:(PKAssembly *)a {
	NSNumber *type = [a pop];
	AZRTechResource *resource = [AZRTechResource resourceWithType:[type integerValue]];
	[a push:resource];
}

- (void)parser:(PKParser *)parser didMatchResourceTypeResource:(PKAssembly *)a {
	[a push:@(AZRTechResourceTypeResource)];
}

- (void)parser:(PKParser *)parser didMatchResourceTypeTech:(PKAssembly *)a {
	[a push:@(AZRTechResourceTypeTech)];
}

- (void)parser:(PKParser *)parser didMatchResourceTypeUnit:(PKAssembly *)a {
	[a push:@(AZRTechResourceTypeUnit)];
}

#pragma mark Resource

- (void)parser:(PKParser *)parser didMatchResource:(PKAssembly *)a {
	AZRTechResource *resource = [a pop];
	NSNumber *handler = [a pop];
	if ([handler isKindOfClass:[NSNumber class]]) {
		resource.handler = [handler integerValue];
	} else
		[a push:handler];

	[a push:resource];
}

- (void)parser:(PKParser *)parser didMatchResourceTargeted:(PKAssembly *)a {
	[a push:@(AZRResourceHandlerTargeted)];
}

- (void)parser:(PKParser *)parser didMatchResourceReplace:(PKAssembly *)a {
	[a push:@(AZRResourceHandlerReplacer)];
}

- (void)parser:(PKParser *)parser didMatchResourceName:(PKAssembly *)a {
	NSString *name = [a pop];
	AZRTechResource *resource = [a pop];
	resource.resource = name;
	[a push:resource];
}

- (void)parser:(PKParser *)parser didMatchResourceAmount:(PKAssembly *)a {
	NSNumber *amount = [a pop];
	AZRTechResource *resource = [a pop];
	resource.amount = [amount integerValue];
	[a push:resource];
}

@end

//
//  AZRObjectDescription
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObjectClassDescription.h"

#import "AZRObject.h"

@interface AZRObjectClassDescription ()

@property (strong) NSDictionary *properties;

@end

@implementation AZRObjectClassDescription
@synthesize parent = _parent;

- (id) initWithName: (NSString *) name {
	if (!(self = [super init]))
		return nil;
	
	self.name = name;
	
	self.properties = [NSMutableDictionary dictionary];
	self.publicProperties = [NSMutableDictionary dictionary];
	
	return self;
}

- (NSString *) instanceClass {
	static NSString *c = @"Object";
	return c;
}

- (void) setParent:(AZRObjectClassDescription *)parent {
	_parent = parent;
	if (!parent)
		return;

	self.multiSelectionGroup = parent.multiSelectionGroup;
}

#pragma mark - Objects

- (AZRObject *) instantiateObject {
	Class instanceClass = NSClassFromString([NSString stringWithFormat:@"AZR%@", self.instanceClass]);
	AZRObject *instance = [[instanceClass alloc] initFromDescription:self];
	[self sharePropertiesForObject:instance];
	[instance setProperties:[instance.properties mutableCopy]];
	return instance;
}

- (BOOL) compatibleWith: (NSSet *) descriptions {
	return [descriptions member:self.name] != nil || (self.parent && [self.parent compatibleWith:descriptions]);
}

#pragma mark - Properties

- (NSDictionary *)replicateProperties {
	NSDictionary *replicated = [[NSDictionary alloc] initWithDictionary:self.properties copyItems:YES];
	return replicated;
}

- (void) sharePropertiesForObject:(AZRObject *)object {
	[self.parent sharePropertiesForObject:object];
	
	[(NSMutableDictionary *)object.properties addEntriesFromDictionary:[self replicateProperties]];
}

- (BOOL) addProperty: (AZRObjectProperty *)property {
//	if ([self hasProperty:property.name])
//		return NO;
//
	[(NSMutableDictionary *)self.properties setObject:property forKey:property.name];
	
	if ((property.type & AZRPropertyTypePublic) == AZRPropertyTypePublic)
		[(NSMutableDictionary *)self.publicProperties setObject:property forKey:property.name];
	
	return YES;
}

- (BOOL) addProperty: (NSString *) propertyName withType: (AZRPropertyType) type {
	if (![self hasProperty:propertyName]) {
		AZRObjectProperty *property = [AZRObjectProperty new];
		[property setName:propertyName];
		[property setType:type];
		return [self addProperty:property];
	}
	
	return NO;
}

- (AZRObjectProperty *) hasProperty: (NSString *) property {
	AZRObjectProperty *p = [self.properties objectForKey:property];
	if ((!p) && self.parent)
		p = [self.parent hasProperty:property];
	
	return p;
}

- (AZRObjectProperty *) hasPublicProperty: (NSString *) property {
	AZRObjectProperty *p = [self.publicProperties objectForKey:property];
	if ((!p) && self.parent)
		p = [self.parent hasPublicProperty:property];
	
	return p;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@: %@(%@)", [self instanceClass], self.name, self.parent ? self.parent.name : @""];
}

@end

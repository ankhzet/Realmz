//
//  AZRObjectProperty.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObjectProperty.h"

@implementation AZRObjectProperty

- (id) initWithName: (NSString *) name {
	if (!(self = [super init]))
		return nil;
	
	self.name = name;
	self.type = AZRPropertyTypeDiscoverable;
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	AZRObjectProperty *copy = [[AZRObjectProperty allocWithZone:zone] initWithName:self.name];
	[copy setType:self.type];
	if (self.numberValue) [copy setNumberValue:[self.numberValue copy]];
	if (self.stringValue) [copy setStringValue:[self.stringValue copy]];
	if (self.vectorValue) [copy setVectorValue:[self.vectorValue copy]];
	return copy;
}

- (NSString *) description {
	NSString *public = ((self.type & AZRPropertyTypePublic) == AZRPropertyTypePublic) ? @"" : @"?";
	NSString *numberValue = self.numberValue ? [NSString stringWithFormat:@": %@", self.numberValue] : @"";
	NSString *stringValue = self.stringValue ? [NSString stringWithFormat:@": %@", self.stringValue] : @"";
	NSString *vectorValue = self.vectorValue ? [NSString stringWithFormat:@": %@", self.vectorValue] : @"";
	return [NSString stringWithFormat:@"*%@%@%@%@%@", public, self.name, numberValue, stringValue, vectorValue];
}

@end

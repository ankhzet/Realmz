//
//  AZRObject.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject.h"
#import "AZRObjectAction.h"

#define ACTION_EXECUTION_TIME 1.0f

@interface AZRObject () {
	AZRObjectAction *action;
	NSTimeInterval actionInitiatedAt;
	NSValue *target;
}

@end

@implementation AZRObject

- (id) initFromDescription: (AZRObjectClassDescription *) description {
	if (!(self = [super init]))
		return nil;
	
	self.classDescription = description;
	self.properties = [NSMutableDictionary dictionary];
	alive = YES;
	
	return self;
}

- (NSString *) AZRClass {
	return self.classDescription.name;
}

- (void) isPerforming:(AZRObjectAction *)performedAction {
	action = performedAction;
	actionInitiatedAt = [NSDate timeIntervalSinceReferenceDate];
}

- (AZRObjectAction *) performedAction {
	if ([NSDate timeIntervalSinceReferenceDate] - actionInitiatedAt < ACTION_EXECUTION_TIME)
		return action;

	return nil;
}

#pragma mark - Properties

- (AZRObjectProperty *) addProperty:(AZRObjectCommonProperty)propertyName {
	AZRObjectProperty *property = [[AZRObjectProperty alloc] initWithName:propertyName];
	[property setType:AZRPropertyTypeProperty | AZRPropertyTypePublic];
	[(NSMutableDictionary *)self.properties setObject:property forKey:propertyName];
	return property;
}

- (float) floatProperty:(AZRObjectCommonProperty)propertyName {
	AZRObjectProperty *property = [[self properties] valueForKey:propertyName];
	return [property.numberValue floatValue];
}

- (float) floatPropertyIncrease:(AZRObjectCommonProperty)propertyName withValue:(float)value {
	AZRObjectProperty *property = [[self properties] valueForKey:propertyName];
	if (!property)
		property = [self addProperty:propertyName];

	float sum = [property.numberValue floatValue] + value;
	property.numberValue = @(sum);

	return sum;
}

#pragma mark - Targeting

- (NSValue *) targetedTo {
	return target;
}

- (void) setTargetedTo:(NSValue *)coordinates {
  target = coordinates;
}

#pragma mark - Stuff

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ <%@>", [self.classDescription instanceClass], self.classDescription];
}

@end

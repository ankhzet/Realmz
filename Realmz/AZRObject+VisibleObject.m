//
//  AZRObject+VisibleObject.m
//  Realmz
//
//  Created by Ankh on 16.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject+VisibleObject.h"

#pragma mark - Properties constants

AZRObjectCommonProperty const AZRObjectCommonPropertyCoordinates = @"coordinates";
AZRObjectCommonProperty const AZRObjectCommonPropertyRadius = @"radius";
AZRObjectCommonProperty const AZRObjectCommonPropertyWeight = @"weight";

AZRObjectCommonProperty const AZRObjectCommonPropertyMaxHealth = @"max-health";
AZRObjectCommonProperty const AZRObjectCommonPropertyHealth = @"health";

#pragma mark - Visible object property getters/setters

@implementation AZRObject (VisibleObject)

- (CGPoint) coordinates {
	AZRObjectProperty *coordinates = [[self properties] valueForKey:AZRObjectCommonPropertyCoordinates];
	
	CGPoint c;
	c.x = [coordinates.vectorValue[0] floatValue];
	c.y = [coordinates.vectorValue[1] floatValue];
	return c;
}

- (void) moveToXY:(CGPoint)targetXY {
	AZRObjectProperty *coordinates = [[self properties] valueForKey:AZRObjectCommonPropertyCoordinates];
	coordinates.vectorValue= @[@(targetXY.x), @(targetXY.y)];
}

- (float) sqrDistanceTo:(CGPoint)point {
	CGPoint pos = [self coordinates];
	return SQR(pos.x - point.x) + SQR(pos.y - point.y);
}

- (float) radius {
	AZRObjectProperty *property = [[self properties] valueForKey:AZRObjectCommonPropertyRadius];
	return [property.numberValue floatValue];
}

- (float) weight {
	AZRObjectProperty *property = [[self properties] valueForKey:AZRObjectCommonPropertyWeight];
	return [property.numberValue floatValue];
}

- (float) maxHealth {
	AZRObjectProperty *property = [[self properties] valueForKey:AZRObjectCommonPropertyMaxHealth];
	return [property.numberValue floatValue];
}

- (float) health {
	AZRObjectProperty *property = [[self properties] valueForKey:AZRObjectCommonPropertyMaxHealth];
	return [property.numberValue floatValue];
}

@end

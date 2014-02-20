//
//  AZRActorNeed.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActorNeed.h"

@implementation AZRActorNeed

// value is at warning level
- (BOOL) isAtYelowZone:(float)value {
	return value * 100 <= self.warnValue;
}
- (BOOL) isAtYelowZone {
	return self.currentValue * 100 <= self.warnValue;
}

// value is at critical level
- (BOOL) isAtRedZone:(float)value {
	return value * 100 <= self.critValue;
}
- (BOOL) isAtRedZone {
	return self.currentValue * 100 <= self.critValue;
}

- (id)copyWithZone:(NSZone *)zone {
	AZRActorNeed *copy = [AZRActorNeed new];
	[copy setName:self.name];
	[copy setCurrentValue:self.currentValue];
	[copy setWarnValue:self.warnValue];
	[copy setCritValue:self.critValue];
	return copy;
}

@end

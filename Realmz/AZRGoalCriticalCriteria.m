//
//  AZRGoalCriticalCriteria.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRGoalCriticalCriteria.h"

#import "AZRActorNeed.h"
#import "AZRNeedManager.h"

@implementation AZRGoalCriticalCriteria

+ (AZRGoalCriticalCriteria *) criteriaForNeed:(NSString *)need warnOnlyIfCritical:(BOOL)critical {
	AZRGoalCriticalCriteria *criteria = [AZRGoalCriticalCriteria new];
	[criteria setNeed:need];
	[criteria setWarnOnlyIfCritical:critical];
	return criteria;
}

- (BOOL) isCritical:(AZRActorNeed *)need {
	return self.warnOnlyIfCritical ? [need isAtRedZone] : [need isAtYelowZone];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@#%@", self.warnOnlyIfCritical ? @"" : @"!", self.need];
}

@end

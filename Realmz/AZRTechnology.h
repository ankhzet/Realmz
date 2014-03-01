//
//  AZRTechnology.h
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRUnifiedResource.h"

typedef NS_ENUM(NSUInteger, AZRTechnologyState) {
	AZRTechnologyStateNormal      = 1 << 0,
	AZRTechnologyStateUnavailable = 1 << 1,
	AZRTechnologyStateInProcess   = 1 << 2,
};

@interface AZRTechnology : AZRUnifiedResource

@property (nonatomic) AZRTechnologyState state;

- (BOOL) isUnavailable;
- (BOOL) isInProcess;

- (BOOL) calcAvailability;
- (void) process:(NSTimeInterval)lastTick;

@end

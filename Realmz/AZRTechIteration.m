//
//  AZRTechIteration.m
//  Realmz
//
//  Created by Ankh on 02.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechIteration.h"

@implementation AZRTechIteration

#pragma mark - Instantiation

+ (instancetype) iterationWithDuration:(NSTimeInterval)duration {
	AZRTechIteration *iteration = [self new];
	iteration->length = duration;
	iteration->startedAt = 0;
	iteration->shouldBeFinishedAt = INFINITY;
	return iteration;
}

- (NSTimeInterval) start {
	startedAt = [NSDate timeIntervalSinceReferenceDate];
	return shouldBeFinishedAt = startedAt + length;
}

- (float) progress {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval progress = (1.f - (shouldBeFinishedAt - now) / length);
	return CONSTRAINT(progress * 100.f, 0, 100.f);
}

- (BOOL) isFinished {
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	return now >= shouldBeFinishedAt;
}

@end

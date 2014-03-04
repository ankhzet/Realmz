//
//  AZRTechIterationSpec.m
//  Realmz
//  Spec for AZRTechIteration
//
//  Created by Ankh on 02.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRTechIteration.h"

SPEC_BEGIN(AZRTechIterationSpec)

describe(@"AZRTechIteration", ^{
	it(@"should be properly initialized", ^{
		AZRTechIteration *iteration = [AZRTechIteration iterationWithDuration:30.f];
		NSTimeInterval finish = [iteration start];
		NSDate *prognosed = [NSDate dateWithTimeIntervalSinceNow:30.f];
		[[theValue((int)finish) should] equal:theValue((int)[prognosed timeIntervalSinceReferenceDate])];
	});

	it(@"should properly calc iteration progress", ^{
		AZRTechIteration *iteration = [AZRTechIteration iterationWithDuration:30.f];
		[[theValue([iteration isFinished]) should] beNo];

		[iteration start];

		[[theValue([iteration isFinished]) should] beNo];

		iteration->startedAt -= 10.f;
		iteration->shouldBeFinishedAt -= 10.f;
		[[theValue((int)[iteration progress]) should] equal:theValue((int) (100 * 10.f / 30.f))];

		iteration->startedAt -= 20.f;
		iteration->shouldBeFinishedAt -= 20.f;

		[[theValue([iteration isFinished]) should] beYes];
	});
});

SPEC_END

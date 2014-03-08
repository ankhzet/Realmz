//
//  AZRTechIteration.h
//  Realmz
//
//  Created by Ankh on 02.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZRTechIteration : NSObject {
	@public
	NSTimeInterval startedAt, length, shouldBeFinishedAt;
	id target;
}

/*!
 @brief Iteration object instantiation.
 Initiates 'startedAt' field to current time.
 @param duration Duration of iteration.
 */
+ (instancetype) iterationWithDuration:(NSTimeInterval)duration;

/*!
 @brief Starts iteration process countdown.
 @RETURN Returns time when iteration will be finished. 
 */
- (NSTimeInterval) start;

/*!
 @brief Returns iteration progress in percents.
 */
- (float) progress;

/*!
 @brief Returns YES if iteration is finished (current time >= iteration->shouldBeFinishedAt).
 */
- (BOOL) isFinished;

@end

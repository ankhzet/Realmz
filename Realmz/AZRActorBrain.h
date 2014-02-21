//
//  AZRGoalSchedule.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AZRScheduledGoal.h"

@interface AZRActorBrain : AZRScheduledGoal

- (id) initForActor:(AZRActor *)theActor;
- (BOOL) think;

- (AZRLogicGoal *) findGoal:(NSString *)goalName;
- (BOOL) scheduleGoal:(NSString *)goalName;

@end

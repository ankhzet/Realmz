//
//  AZRScheduledGoal.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AZRLogicGoal.h"

@class AZRObject;

@interface AZRScheduledGoal : NSObject

@property (nonatomic, weak) AZRScheduledGoal *parent;
@property (nonatomic, weak) AZRLogicGoal *requestor;
@property (nonatomic) AZRLogicGoal *goal;
@property (nonatomic) NSArray *subGoals;
@property (nonatomic) NSSet *selectedTargets;

// выполнение запланированной цели для `актора, основная "рабочая лошадка"
- (BOOL) executeforActor:(AZRActor *)actor;

// планирование целей
- (AZRScheduledGoal *) scheduleSubGoal:(AZRLogicGoal *) goal;
+ (AZRScheduledGoal *) scheduleSubGoal:(AZRLogicGoal *) goal forParent:(AZRScheduledGoal *) parentScheduledGoal;
- (AZRScheduledGoal *) isSubGoal:(AZRLogicGoal *)goal;

- (AZRGoalTargetSelector *) selectTargetsKnownByActor:(AZRActor *)actor;

- (BOOL) isAchieved;
- (void) setAchieved:(BOOL)achieved;
- (BOOL) isExecuted;
- (void) setExecuted:(BOOL)executed;

@end

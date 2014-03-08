//
//  AZRLogicGoal.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRUnifiedResource.h"

@class AZRScheduledGoal;
@class AZRActor;
@class AZRGoalTargetSelector;
@class AZRGoalCriticalCriteria;

typedef NS_ENUM(NSUInteger, AZRLogicGoalOwnageType) {
	AZRLogicGoalOwnageTypeRootNode = -1,
	AZRLogicGoalOwnageTypePlainNode = 0,
	AZRLogicGoalOwnageTypeIfNode = 1,
	AZRLogicGoalOwnageTypeWhenNode = 2,
};

@interface AZRLogicGoal : AZRUnifiedResource <NSCopying>

@property (nonatomic) AZRGoalTargetSelector *targetSelector;
@property (nonatomic) NSSet *criterias;
@property (nonatomic) AZRLogicGoalOwnageType ownage;
@property (nonatomic) BOOL fireIfNotAchieved;
@property (nonatomic, weak) AZRLogicGoal *parent;

+ (id) newGoalWithName:(NSString *)goalName;

// базовый уровень достижения цели
// для простой цели - выполнение простых под-целей
// для цели-действия - выполнение действия и т.д.
// переопределяется в подклассах
- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved;

- (void) addCriteria:(AZRGoalCriticalCriteria *)criteria;

- (void) addSubGoal:(AZRLogicGoal *)goal;
- (NSArray *) subGoalsWithOwnage:(AZRLogicGoalOwnageType)ownage;
- (AZRLogicGoal *) findGoal:(NSString *)goalName;
- (AZRLogicGoal *) findGoal:(NSString *)goalName ofClass:(Class)goalClass;

// критично ли выполнение текущей цели для `актора?
- (BOOL) isCriticalFor:(AZRActor *)actor;

// цель, не содержащая под-целей
- (BOOL) isBlindNode;
- (void) connectBlindNodes:(AZRLogicGoal *)rootNode;

- (NSString *) typeIdentifier;

@end

//
//  AZRActor.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject.h"
#import "AZRActorObjectsMemory.h"

@class AZRLogicGoal, AZRActorBrain;

typedef NSString* AZRActorNeedIdentifier;

extern AZRActorNeedIdentifier const AZRActorNeedExitement;
extern AZRActorNeedIdentifier const AZRActorNeedThirst;
extern AZRActorNeedIdentifier const AZRActorNeedHunger;

@interface AZRActor : AZRObject {
@public
	AZRActorBrain *brain;
}

@property (nonatomic) NSDictionary *needs;
@property (nonatomic) AZRActorObjectsMemory *knownObjects;

- (NSDictionary *) pickImportantNeeds;

- (void) initBrains:(AZRLogicGoal *)logic;
- (BOOL) think:(NSTimeInterval)timestamp;

- (BOOL) scheduleGoal:(NSString *)goalName imperative:(BOOL)imperative;
- (BOOL) scheduleGoal:(NSString *)goalName targetedAt:(NSValue *)coordinates imperative:(BOOL)imperative;

@end

//
//  AZRActorDescription.h
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObjectClassDescription.h"

#import "AZRLogicGoal.h"

@interface AZRActorClassDescription : AZRObjectClassDescription
@property (nonatomic) AZRLogicGoal *actorLogic;
@property (nonatomic) NSArray *needs;
@property (nonatomic) NSNumber *viewSight;

@end

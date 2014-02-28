//
//  AZRGoalTargetSelector.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRUnifiedResource.h"

@class AZRGoalPropertySelector;
@class AZRObject;
@class AZRActorObjectsMemory;

@interface AZRGoalTargetSelector : AZRUnifiedResource
@property (nonatomic) AZRGoalPropertySelector *propertySelector;
@property (nonatomic) BOOL matchAlways;
@property (nonatomic) BOOL negative;
@property (nonatomic) NSArray *filters;

- (void) addFilter:(AZRGoalTargetSelector *) filter;

- (NSSet *) scanMemory: (AZRActorObjectsMemory *) memory;
- (NSSet *) filterObjects:(NSSet *)targets asKnownBy: (AZRActorObjectsMemory *) memory;
- (BOOL) objectMatch:(AZRObject *)object asKnownBy: (AZRActorObjectsMemory *) memory;

@end

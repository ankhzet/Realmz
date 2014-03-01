//
//  AZRTechnology.h
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRUnifiedResource.h"

typedef NS_ENUM(NSUInteger, AZRTechnologyState) {
	// normal, unimplemented tech
	AZRTechnologyStateNormal           = 1 << 0,
	// unimplementable tech, or not enought resources
	AZRTechnologyStateUnavailable      = 1 << 1,
	// tech in process of implementation
	AZRTechnologyStateInProcess        = 1 << 2,
	// not all of required techs are implemented
	AZRTechnologyStateNotImplementable = 1 << 3,
};

@class AZRTechTree;
@interface AZRTechnology : AZRUnifiedResource

@property (nonatomic) AZRTechTree *techTree;

+ (instancetype) technology:(NSString *)techName inTechTree:(AZRTechTree *)techsTree;

/*!
 @brief Checks required techs implementation state.
 @return Returns YES if all required techs implemented, NO otherwise.
 */
- (BOOL) isImplementable;

/*!
 @brief Returns YES if implemented.
 */
- (BOOL) isImplemented;

/*!
 @brief Returns YES if not implementable or not enought resources.
 */
- (BOOL) isUnavailable;

/*!
 @brief Returns YES if in process of implementation.
 */
- (BOOL) isInProcess;

/*!
 @brief Add tech, required for implementation.
 @return Returns corresponding tech, if finded in tech tree.
 */
- (AZRTechnology *) addRequired:(NSString *)techName;

/*!
 @brief Fetch all techs, dependant from message-receiver tech.
 */
- (NSArray *) fetchDependent;

- (BOOL) calcAvailability;
- (void) process:(NSTimeInterval)lastTick;

@end

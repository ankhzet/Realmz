//
//  AZRTechnology.h
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRUnifiedResource.h"
#import "AZRTechResource.h"

typedef NS_ENUM(NSUInteger, AZRTechnologyState) {
	// normal, unimplemented tech
	AZRTechnologyStateNormal           = 1 << 0,
	// unimplementable tech, or not enought resources
	AZRTechnologyStateUnavailable      = 1 << 1,
	// tech in process of implementation
	AZRTechnologyStateInProcess        = 1 << 2,
	// not all of required techs are implemented
	AZRTechnologyStateNotImplementable = 1 << 3,
	// implemented tech
	AZRTechnologyStateImplemented      = 1 << 4,
};

@class AZRTechTree;
@interface AZRTechnology : AZRUnifiedResource

@property (nonatomic) NSString *summary;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *version;

@property (nonatomic, weak) AZRTechTree *techTree;
@property (nonatomic) AZRTechnologyState state;
@property (nonatomic) NSArray *requiredTechs;
@property (nonatomic) NSUInteger multiple;
@property (nonatomic) float iterationTime;
@property (nonatomic) BOOL final;
@property (nonatomic) NSArray *iterations;

+ (instancetype) technology:(NSString *)techName inTechTree:(AZRTechTree *)techsTree;
- (id)initWithName:(NSString *)techName;

- (BOOL) implement:(BOOL)implement withTarget:(id)target;

/* **************** State ******************************* */

- (BOOL) isImplementable;
- (BOOL) isImplemented;
- (BOOL) isUnavailable;
- (BOOL) isInProcess;

- (void) forceImplementable:(BOOL)implementable;
- (void) forceImplemented:(BOOL)implemented;
- (void) forceUnavailable:(BOOL)unavailable;
- (void) forceInProcess:(BOOL)inProcess;


/* **************** Dependencies ************************ */

- (AZRTechnology *) addRequired:(NSString *)techName;
- (BOOL) isDependentOf:(AZRTechnology *)tech;
- (NSArray *) fetchDependent;
- (void) dependency:(AZRTechnology *)tech implemented:(BOOL)implemented;


/* **************** Drains & gains ********************** */

- (AZRTechResource *) addDrain:(AZRTechResourceType)resourceName;
- (NSArray *) getDrained:(AZRTechResourceType)resourceType;

- (AZRTechResource *) addGain:(AZRTechResourceType)resourceName;
- (NSArray *) getGained:(AZRTechResourceType)resourceType;


/* **************** Processing ************************** */

- (void) process:(NSTimeInterval)lastTick;

@end

//
//  AZRTechTree.h
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRUnifiedResource.h"

@class AZRTechnology;
@interface AZRTechTree : AZRUnifiedResource

@property (nonatomic) NSMutableDictionary *technologies;

/*! @brief Instantiating tech tree.*/
+ (instancetype) techTree;

- (void) process:(NSTimeInterval)lastTick;

/*! @brief Adding tech to tech tree.*/
- (void) addTech:(AZRTechnology *)technology;
/*! @brief Find tech in tech tree.*/
- (AZRTechnology *) techNamed:(NSString *)techName;
/*! @brief Remove tech from tech tree.*/
- (AZRTechnology *) removeTech:(NSString *)techName;

/*! @brief Returns all techs, groupped by their states. */
- (NSDictionary *) fetchTechStates;

@end

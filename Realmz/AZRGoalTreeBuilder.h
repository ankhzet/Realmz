//
//  AZRGoalTreeBuilder.h
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRLogicGoal;

@interface AZRGoalTreeBuilder : NSObject

- (AZRLogicGoal *) buildTreeFromLogicFile:(NSString *)source;
- (AZRLogicGoal *) buildTreeFromString:(NSString *)source;

@end

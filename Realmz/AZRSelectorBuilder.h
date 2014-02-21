//
//  AZRSelectorBuilder.h
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRGoalTargetSelector;

@interface AZRSelectorBuilder : NSObject

- (AZRGoalTargetSelector *) buildSelectorFromString:(NSString *)source;

@end

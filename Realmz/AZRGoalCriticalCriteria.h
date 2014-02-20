//
//  AZRGoalCriticalCriteria.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRActorNeed;

@interface AZRGoalCriticalCriteria : NSObject

// потребность, на которую ориентируется критерий
@property (nonatomic) NSString *need;

// критерий реагирует на "красный" уровень потребности? (иначе - желтый)
@property (nonatomic) BOOL warnOnlyIfCritical;

+ (AZRGoalCriticalCriteria *) criteriaForNeed:(NSString *)need warnOnlyIfCritical:(BOOL)critical;

- (BOOL) isCritical:(AZRActorNeed *)need;

@end

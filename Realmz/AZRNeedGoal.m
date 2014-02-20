//
//  AZRNeedGoal.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRNeedGoal.h"

@implementation AZRNeedGoal

- (NSString *) typeIdentifier {
	return @"#";
}

- (AZRLogicGoal *) execute:(AZRScheduledGoal *) scheduled forActor: (AZRActor *)actor achieved:(BOOL*)achieved {
	*achieved = NO;
	
	// no sub-nodes except conditional & delayed by default
	return nil;
}


@end

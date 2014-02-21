//
//  AZRActionIntent.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActionIntent.h"

#import "AZRObjectClassDescription.h"
#import "AZRObjectProperty.h"
#import "AZRObject.h"
#import "AZRObjectAction.h"
#import "AZRActionManager.h"
#import "AZRActor.h"

@implementation AZRActionIntent

- (BOOL) execute {
//	AZRObjectProperty *property = [self.target.description hasProperty:self.action];
//	if (!property) {
//		[AZRLogger log:NSStringFromClass([self class]) withMessage:@"%%{%@} not applies to %@]", self.action, self.target.description.name];
//		return NO;
//	}
	
	AZRObjectAction *action = [AZRActionManager getAction:self.action];
	if (!action)
		return NO;

	[self.initiator isPerforming:action];
  return [action executeOn:self.target withInitiator:self.initiator];
}

@end

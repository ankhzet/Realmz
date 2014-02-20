//
//  AZRActionManager.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActionManager.h"

#import "AZRObjectAction.h"

@interface AZRActionManager ()
{NSMutableDictionary *actions;}

@end

@implementation AZRActionManager

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self->actions = [NSMutableDictionary dictionary];
	
	return self;
}

+ (AZRActionManager *) getInstance {
	static AZRActionManager *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [AZRActionManager new];
	});
	return instance;
}

- (BOOL) registerAction: (AZRObjectAction *) action {
	BOOL valid = [action aquireDetails];
	
	if (valid)
		self->actions[action.name] = action;
	
	return valid;
}

+ (AZRObjectAction *) getAction: (NSString *) actionName {
	return [[self getInstance] getAction:actionName];
}

- (AZRObjectAction *) getAction: (NSString *) actionName {
	AZRObjectAction *action = self->actions[actionName];
	if (!action) {
		action = [[AZRObjectAction alloc] initWithName:actionName];
		if (![self registerAction:action]) {
			action = nil;
		}
	}
	return action;
}

@end

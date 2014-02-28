//
//  AZRObjectDescriptionManager.m
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObjectClassDescriptionManager.h"

#import "AZRObjectClassDescription.h"
#import "AZRClassDescriptionLoader.h"

@interface AZRObjectClassDescriptionManager () {
	NSMutableDictionary *descriptions;
}

@end

@implementation AZRObjectClassDescriptionManager

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self->descriptions = [NSMutableDictionary dictionary];
	return self;
}

+ (AZRObjectClassDescriptionManager *) getInstance {
	static AZRObjectClassDescriptionManager *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [AZRObjectClassDescriptionManager new];
	});
	return instance;
}

- (AZRObjectClassDescription *) getDescription:(NSString *)descriptionName {
	AZRObjectClassDescription *description = self->descriptions[descriptionName];
	
	if (!description) {
		// not loaded yet, try to load
		AZRClassDescriptionLoader *loader = [AZRClassDescriptionLoader new];
		description = [loader loadFromFile:descriptionName];
		
		if (description) {
			self->descriptions[descriptionName] = description;
		}
	}
	return description;
}

@end

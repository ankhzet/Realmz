//
//  AZRActorDescription.m
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRActorClassDescription.h"
#import "AZRActor.h"
#import "AZRActorNeed.h"

@implementation AZRActorClassDescription

- (NSString *) instanceClass {
	static NSString *c = @"Actor";
	return c;
}

- (AZRObject *) instantiateObject {
	AZRActor *actor = (AZRActor *)[super instantiateObject];
	[actor initBrains:self.actorLogic];
	[actor setNeeds:[self replicateNeeds]];
	return actor;
}

- (NSDictionary *) replicateNeeds {
	NSMutableDictionary *temp = [NSMutableDictionary dictionary];
	
	for (AZRActorNeed *need in self.needs) {
    [temp setObject:[need copy] forKey:need.name];
	}
	return [temp copy];
}

@end

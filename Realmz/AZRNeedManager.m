//
//  AZRNeedManager.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRNeedManager.h"

#import "AZRActorNeed.h"

@interface AZRNeedManager ()
@property (nonatomic) NSMutableDictionary *needs;
@end

@implementation AZRNeedManager

+ (AZRNeedManager *) getInstance {
	static AZRNeedManager *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [AZRNeedManager new];
	});
	return instance;
}

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self.needs = [NSMutableDictionary dictionary];
	
	return self;
}

+ (AZRActorNeed *) getNeedDescription:(NSString *)needIdentifier {
	AZRActorNeed *need = [self getInstance].needs[needIdentifier];
	if (!need) {
		need = [AZRActorNeed new];
		[need setName:needIdentifier];
		[need setCurrentValue:1.0f];
		[need setWarnValue:50.0f];
		[need setCritValue:25.0f];
	}
	return need;
}

@end

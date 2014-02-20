//
//  AZRLogger.m
//  Realmz
//
//  Created by Ankh on 16.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRLogger.h"

@interface AZRLogger () {
	NSMutableDictionary *loggedInfo;
}

@end
@implementation AZRLogger

+ (AZRLogger *) getInstance {
	static AZRLogger *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [AZRLogger new];
		instance->loggedInfo = [NSMutableDictionary dictionary];
	});
	return instance;
}

+ (void) clearLog:(NSString *)key {
	AZRLogger *instance = [self getInstance];
	if (key)
		instance->loggedInfo[key] = [NSMutableDictionary dictionary];
	else
		instance->loggedInfo = [NSMutableDictionary dictionary];
}

+ (void) log:(NSString *)key withMessage:(NSString *)message, ... {
	return;
	va_list args;
	va_start(args, message);

	NSString *formatted = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);

	AZRLogger *instance = [self getInstance];
	if (key && [instance hasMessage:formatted forKey:key]) {
		return;
	}
	
	NSLog(@"%@", formatted);
	if (key) {
		NSMutableDictionary *keyStorage = instance->loggedInfo[key];
		if (!keyStorage) {
			keyStorage = [NSMutableDictionary dictionary];
			instance->loggedInfo[key] = keyStorage;
		}
		[keyStorage setObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:formatted];
	}
}

- (BOOL) hasMessage:(NSString *)message forKey:(NSString *)key {
	NSMutableDictionary *keyStorage = loggedInfo[key];

	NSNumber *timestamp = keyStorage ? keyStorage[message] : nil;
	
	return !!timestamp;// && ([NSDate timeIntervalSinceReferenceDate] - [timestamp doubleValue] < 10.f);
}

@end

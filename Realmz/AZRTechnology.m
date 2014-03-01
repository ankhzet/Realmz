//
//  AZRTechnology.m
//  Realmz
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechnology.h"
#import "AZRTechnology+Protected.h"

@implementation AZRTechnology

#pragma mark - Intantiation

+ (instancetype) technology:(NSString *)techName inTechTree:(AZRTechTree *)techsTree {
	return nil;
}

#pragma mark - Tech state

- (BOOL) isImplementable {
	return NO;
}

- (BOOL) isImplemented {
	return NO;
}

- (BOOL) isUnavailable {
	return NO;
}

- (BOOL) isInProcess {
	return NO;
}

#pragma mark - Dependencies

- (AZRTechnology *) addRequired:(NSString *)techName {
	return nil;
}

- (NSArray *) fetchDependent {
	return nil;
}

#pragma mark - Availability

- (BOOL) calcAvailability {
	return NO;
}

#pragma mark - Iterational processing

- (void) process:(NSTimeInterval)lastTick {

}


@end

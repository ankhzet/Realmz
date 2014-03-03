//
//  AZRInGameResourceManager.m
//  Realmz
//
//  Created by Ankh on 03.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRInGameResourceManager.h"

@interface AZRInGameResourceManager ()
@property (nonatomic) NSMutableDictionary *resources;
@end
@implementation AZRInGameResourceManager

#pragma mark - Instantiation

+ (instancetype) manager {
}

#pragma mark - Resource managing

- (AZRInGameResource *) addResource:(NSString *)resourceName {
}

- (AZRInGameResource *) addResource:(NSString *)resourceName controlledBy:(AZRInGameResourceController *)controller {
}

- (AZRInGameResource *) resourceNamed:(NSString *)resourceName {
}

- (AZRInGameResource *) removeResource:(NSString *) resourceName {
}

- (int) resource:(AZRInGameResource *)resource addAmount:(int)amount {
}

@end

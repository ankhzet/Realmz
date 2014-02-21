//
//  AZRActorObjectsMemory.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObject;

@interface AZRActorObjectsMemory : NSObject

- (NSDictionary *) allMemory;
- (void) objectSeen:(AZRObject *)object;
- (void) objectInspected:(AZRObject *)object;
- (void) property:(NSString *)property discoveredForObject:(AZRObject *)object;
- (BOOL) knownProperty:(NSString *)property forObject:(AZRObject *)object;

@end

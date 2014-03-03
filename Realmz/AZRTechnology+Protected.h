//
//  AZRTechnology+Protected.h
//  Realmz
//
//  Protected methods
//
//  Created by Ankh on 01.03.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRTechnology.h"

@interface AZRTechnology ()

@property (nonatomic) NSMutableDictionary *drains;
@property (nonatomic) NSMutableDictionary *gains;

@end

@interface AZRTechnology (Protected)

- (BOOL) calcAvailability;


- (BOOL) preImplement:(id)target;
- (void) postImplement:(id)target;
- (void) revertPreImplement:(id)target;

- (void) pushIteration:(id)target;

- (void) processProgress:(NSTimeInterval)lastTick;

@end

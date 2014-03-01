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
@property (nonatomic) AZRTechnologyState state;


@end

@interface AZRTechnology (Protected)

- (void) preImplement;
- (void) postImplement;
- (void) revertPreImplement;

- (void) dependencyImplemented:(AZRTechnology *)requiredTech;

@end

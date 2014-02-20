//
//  AZRActorNeed.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZRActorNeed : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) float currentValue;
@property (nonatomic) float warnValue;
@property (nonatomic) float critValue;

// value is at warning level
- (BOOL) isAtYelowZone:(float)value;
- (BOOL) isAtYelowZone;
// value is at critical level
- (BOOL) isAtRedZone:(float)value;
- (BOOL) isAtRedZone;

@end

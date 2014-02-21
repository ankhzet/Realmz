//
//  AZRLogger.h
//  Realmz
//
//  Created by Ankh on 16.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZRLogger : NSObject
+ (void) log:(NSString *)key withMessage:(NSString *)message, ...;
+ (void) clearLog:(NSString *)key;
@end

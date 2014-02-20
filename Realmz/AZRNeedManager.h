//
//  AZRNeedManager.h
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRActorNeed;

@interface AZRNeedManager : NSObject
+ (AZRActorNeed *) getNeedDescription:(NSString *)needIdentifier;
@end

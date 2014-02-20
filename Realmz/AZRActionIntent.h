//
//  AZRActionIntent.h
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObject, AZRActor;

@interface AZRActionIntent : NSObject

@property (nonatomic) AZRActor *initiator;
@property (nonatomic) AZRObject *target;
@property (nonatomic) NSString *action;

- (BOOL) execute;

@end

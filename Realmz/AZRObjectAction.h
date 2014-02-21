//
//  AZRObjectAction.h
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRActionIntent;
@class AZRObject;
@class AZRActor;

typedef NSString * AZRActorCommonAction;

@interface AZRObjectAction : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *icon;
@property (nonatomic) NSString *actionDescription;
@property (nonatomic) NSMutableSet *validTargets;

- (id) initWithName: (NSString *) name;
- (BOOL) aquireDetails;

- (BOOL) applyableTo: (AZRObject *) target;

- (BOOL) executeOn: (AZRObject *)target withInitiator:(AZRActor *)initiator;

@end

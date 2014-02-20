//
//  AZRObject+Actions.h
//  Realmz
//
//  Created by Ankh on 16.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject.h"
#import "AZRObjectAction.h"

@class AZRActor;

extern AZRActorCommonAction const AZRActorCommonActionInspect;
extern AZRActorCommonAction const AZRActorCommonActionComeTo;

@interface AZRObject (Actions)

- (BOOL) actionInspectWithInitiator:(AZRActor *)initiator;
- (BOOL) actionComeToWithInitiator:(AZRActor *)initiator;

@end

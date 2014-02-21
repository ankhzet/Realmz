//
//  AZRActionManager.h
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObjectAction;

@interface AZRActionManager : NSObject

+ (AZRObjectAction *) getAction: (NSString *) actionName;

@end


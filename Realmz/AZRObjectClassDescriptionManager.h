//
//  AZRObjectDescriptionManager.h
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObjectClassDescription;

@interface AZRObjectClassDescriptionManager : NSObject

+ (AZRObjectClassDescriptionManager *) getInstance;

- (AZRObjectClassDescription *) getDescription:(NSString *)descriptionName;

@end

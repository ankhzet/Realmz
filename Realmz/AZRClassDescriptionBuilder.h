//
//  AZRDescriptionBuilder.h
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObjectClassDescription;

@interface AZRClassDescriptionBuilder : NSObject

- (AZRObjectClassDescription *) buildDescriptionFromDescriptionFile:(NSString *)source;
- (AZRObjectClassDescription *) buildDescriptionFromString:(NSString *)source;

@end

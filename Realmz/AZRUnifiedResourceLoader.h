//
//  AZRUnifiedResourceLoader.h
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZRCommonParser.h"

@interface AZRUnifiedResourceLoader : NSObject

- (id) loadFromFile:(NSString *)source;
- (id) loadFromString:(NSString *)source;

- (AZRUnifiedFileType) resourceType;
- (NSString *) grammar;

@end

//
//  AZRObjectRenderer.h
//  Realmz
//
//  Created by Ankh on 20.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject.h"

@interface AZRObjectRenderer : NSObject

- (void) render:(AZRObject *)object;
- (void) renderInterface:(AZRObject *)object;

@end

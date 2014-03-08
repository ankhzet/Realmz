//
//  AZRLogicParser.h
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/ParseKit.h>

typedef NSString* AZRUnifiedFileType;
extern AZRUnifiedFileType const AZRUnifiedFileTypeGrammar;

@class PKParser;

@interface AZRCommonParser : NSObject

+ (NSURL *) getUnifiedFileURL:(NSString *)fileName fileType:(AZRUnifiedFileType)type;
+ (PKParser *) parserForGrammar:(NSString *)grammar assembler:(id)assembler;

@end

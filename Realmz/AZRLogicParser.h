//
//  AZRLogicParser.h
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* AZRLogicsFileType;

extern AZRLogicsFileType const AZRLogicsFileTypeGrammar;
extern AZRLogicsFileType const AZRLogicsFileTypeLogic;
extern AZRLogicsFileType const AZRLogicsFileTypeObjectDescription;

@class PKParser;

@interface AZRLogicParser : NSObject

+ (NSURL *) getLogicsFileURL:(NSString *)fileName fileType:(AZRLogicsFileType)type;
+ (PKParser *) parserForGrammar:(NSString *)grammar assembler:(id)assembler;

@end

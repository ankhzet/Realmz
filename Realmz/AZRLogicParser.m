//
//  AZRLogicParser.m
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRLogicParser.h"
#import <ParseKit/ParseKit.h>

AZRLogicsFileType const AZRLogicsFileTypeGrammar = @"grammar";
AZRLogicsFileType const AZRLogicsFileTypeLogic = @"logic";
AZRLogicsFileType const AZRLogicsFileTypeObjectDescription = @"desc";

@implementation AZRLogicParser

+ (NSURL *) getLogicsFileURL:(NSString *)fileName fileType:(AZRLogicsFileType)type {
	return [[NSBundle mainBundle] URLForResource:fileName withExtension:type];
}

+ (PKParser *) parserForGrammar:(NSString *)grammar assembler:(id)assembler {
	NSError *error = nil;
	NSString *grammarContents = [NSString stringWithContentsOfURL:[self getLogicsFileURL:grammar fileType:AZRLogicsFileTypeGrammar] encoding:NSUTF8StringEncoding error:&error];
	
	if (!grammarContents) {
		[AZRLogger log:nil withMessage:@"Error while loading parser grammar: %@", [error localizedDescription]];
		return nil;
	}
	
	PKParser *parser = [[PKParserFactory factory] parserFromGrammar:grammarContents assembler:assembler error:&error];
	if (!parser) {
		[AZRLogger log:nil withMessage:@"Error prepare parser: %@", [error localizedDescription]];
	}
	
	[parser.tokenizer setTokenizerState:parser.tokenizer.commentState from: '/' to:'/'];
	[parser.tokenizer.commentState addSingleLineStartMarker: @"//"];
	
	[parser.tokenizer setTokenizerState:parser.tokenizer.commentState from: '/' to: '/'];
	[parser.tokenizer.commentState addMultiLineStartMarker: @"/*" endMarker: @"*/"];

	return parser;
}

@end

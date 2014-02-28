//
//  AZRUnifiedResourceLoader.m
//  Realmz
//
//  Created by Ankh on 26.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRUnifiedResourceLoader.h"
#import "AZRUnifiedResource.h"
#import "AZRCommonParser.h"
#import <ParseKit/ParseKit.h>

@interface AZRUnifiedResourceLoader ()
@property (nonatomic) NSString *summary;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *version;
@end

@implementation AZRUnifiedResourceLoader

#pragma mark - Customization methods

- (AZRUnifiedFileType) resourceType {
	return nil;
}

- (NSString *) grammar {
	return nil;
}

#pragma mark - Loading methods

- (id) loadFromFile:(NSString *)source {
	NSURL *codeURL = [AZRCommonParser getUnifiedFileURL:source fileType:[self resourceType]];
	if (!codeURL) {
		[AZRLogger log:nil withMessage:@"Can't find \".%@\" resource file for [%@]", [self resourceType], source];
		return nil;
	}

	NSError *error = nil;
	NSString *fileContents = [NSString stringWithContentsOfURL:codeURL encoding:NSUTF8StringEncoding error:&error];
	if (!fileContents) {
		[AZRLogger log:nil withMessage:@"Can't load resource file for [%@]: %@", source, [error localizedDescription]];
		return nil;
	}

	return [self loadFromString:fileContents];
}

- (id) loadFromString:(NSString *)source {

	PKParser *parser = [AZRCommonParser parserForGrammar:[self grammar] assembler:self];

	NSError *error = nil;
	AZRUnifiedResource *result = [parser parse:source error:&error];
	PKReleaseSubparserTree(parser);
	if (!result)
		[AZRLogger log:nil withMessage:@"Error parsing resource description: %@", [error localizedDescription]];
	else
		return result;

	return nil;
}

#pragma mark - Common parser methods

- (void)parser:(PKParser *)parser didMatchSummary:(PKAssembly *)a {
	NSString *string = [a pop];
	AZRUnifiedResource *resource = [a pop];
	[(id)resource setSummary:string];
	[a push:resource];
}

- (void)parser:(PKParser *)parser didMatchVersion:(PKAssembly *)a {
	NSString *string = [a pop];
	AZRUnifiedResource *resource = [a pop];
	[(id)resource setVersion:string];
	[a push:resource];
}

- (void)parser:(PKParser *)parser didMatchAuthor:(PKAssembly *)a {
	NSString *string = [a pop];
	AZRUnifiedResource *resource = [a pop];
	[(id)resource setAuthor:string];
	[a push:resource];
}

- (void)parser:(PKParser *)parser didMatchNumeric:(PKAssembly *)a {
	[a push:@([(PKToken *)[a pop] floatValue])];
}

- (void)parser:(PKParser *)parser didMatchString:(PKAssembly *)a {
	NSString *string = [(PKToken *)[a pop] stringValue];
	string = [string substringWithRange:NSMakeRange(1, [string length] - 2)];
	[a push:string];
}

- (void)parser:(PKParser *)parser didMatchVector:(PKAssembly *)a {
	id element;
	NSMutableArray *vector = [NSMutableArray array];

	// pushing all till '[' marker
	while (![(element = [a pop]) isKindOfClass:[PKToken class]]) {
		[vector insertObject:element atIndex:0];
	}

	[a push:[vector copy]];
}


@end

//
//  AZRDescriptionBuilder.m
//  Realmz
//
//  Created by Ankh on 07.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRClassDescriptionBuilder.h"
#import <ParseKit/ParseKit.h>
#import "AZRLogicParser.h"
#import "AZRObjectClassDescription.h"
#import "AZRActorClassDescription.h"
#import "AZRObjectClassDescriptionManager.h"
#import "AZRGoalTreeBuilder.h"
#import "AZRActorNeed.h"
#import "AZRNeedManager.h"

#define _LOG_ASSEMBLY 0

#if _LOG_ASSEMBLY
#define LOG_ASSEMBLY() NSLog(@"\n\n%s\n%@\n\n", __PRETTY_FUNCTION__, a);
#else
#define LOG_ASSEMBLY() 

#endif


@implementation AZRClassDescriptionBuilder
	
- (AZRObjectClassDescription *) buildDescriptionFromDescriptionFile:(NSString *)source {
	NSURL *codeURL = [AZRLogicParser getLogicsFileURL:source fileType:AZRLogicsFileTypeObjectDescription];
	if (!codeURL) {
		[AZRLogger log:nil withMessage:@"Can't find logics file for object [%@] description", source];
		return nil;
	}
	
	NSError *error = nil;
	NSString *descriptionCode = [NSString stringWithContentsOfURL:codeURL encoding:NSUTF8StringEncoding error:&error];
	if (!descriptionCode) {
		[AZRLogger log:nil withMessage:@"Can't load logics file for object [%@] description: %@", source, [error localizedDescription]];
		return nil;
	}
	
	return [self buildDescriptionFromString:descriptionCode];
}
	
- (AZRObjectClassDescription *) buildDescriptionFromString:(NSString *)source {
	
	PKParser *parser = [AZRLogicParser parserForGrammar:@"object" assembler:self];
	
	NSError *error = nil;
	AZRObjectClassDescription *result = [parser parse:source error:&error];
	PKReleaseSubparserTree(parser);
	if (!result)
		[AZRLogger log:nil withMessage:@"Error parsing object description: %@", [error localizedDescription]];
	else
		return result;
	
	return nil;
}

#pragma mark - Description creation

- (void)parser:(PKParser *)parser didMatchObjectNameAndParent:(PKAssembly *)a {
	LOG_ASSEMBLY();
	
	AZRObjectClassDescription *parent = nil;
	NSString *descriptionName;
	id top = [a pop];
	if ([top isKindOfClass:[AZRObjectClassDescription class]]) { //parent class
		parent = top;
		descriptionName = [a pop];
	} else
	descriptionName = top;
	
	Class objectClass = [a pop];
	AZRObjectClassDescription *description = [[objectClass alloc] initWithName:descriptionName];
	
	if (parent)
		[description setParent:parent];
	
	[a push:description];
	LOG_ASSEMBLY();
}
	
- (void)parser:(PKParser *)parser didMatchPlainObject:(PKAssembly *)a {
	[a push:[AZRObjectClassDescription class]];
}
	
- (void)parser:(PKParser *)parser didMatchActorObject:(PKAssembly *)a {
	[a push:[AZRActorClassDescription class]];
}
	
- (void)parser:(PKParser *)parser didMatchObjectParent:(PKAssembly *)a {
	LOG_ASSEMBLY();
	
	NSString *descriptonName = [a pop];
	AZRObjectClassDescription *parent = [[AZRObjectClassDescriptionManager getInstance] getDescription:descriptonName];
	
	NSAssert(parent, @"Failed to build object description: parent description can't be loaded");

	[a push:parent];
	
	LOG_ASSEMBLY();
}

#pragma mark - Object info (author, summary etc)

- (void)parser:(PKParser *)parser didMatchSummary:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *string = [a pop];
	AZRObjectClassDescription *description = [a pop];
	[description setSummary:string];
	[a push:description];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchViewSight:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSNumber *numeric = [a pop];
	AZRActorClassDescription *description = [a pop];
	NSAssert([description isKindOfClass:[AZRActorClassDescription class]], @"Failed to attach logic to object: current object isn't an actor");

	[description setViewSight:@([numeric floatValue])];// reconvert to float, if needed
	[a push:description];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchSelectionGroup:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSNumber *numeric = [a pop];
	AZRActorClassDescription *description = [a pop];
	[description setMultiSelectionGroup:[numeric floatValue]];
	[a push:description];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchVersion:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *string = [a pop];
	AZRObjectClassDescription *description = [a pop];
	[description setVersion:string];
	[a push:description];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchAuthor:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *string = [a pop];
	AZRObjectClassDescription *description = [a pop];
	[description setAuthor:string];
	[a push:description];
	LOG_ASSEMBLY();
}
	
- (void)parser:(PKParser *)parser didMatchLogic:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *string = [a pop];
	
	AZRActorClassDescription *description = [a pop];
	NSAssert([description isKindOfClass:[AZRActorClassDescription class]], @"Failed to attach logic to object: current object isn't an actor");
	
	AZRGoalTreeBuilder *builder = [AZRGoalTreeBuilder new];
	AZRLogicGoal *logic = [builder buildTreeFromLogicFile:string];
	NSAssert(logic, @"Failed to attach logic to object: can't load logic");
	[logic setName:[NSString stringWithFormat:@"%@_logic", description.name]];
	[description setActorLogic:logic];
	
	[a push:description];
	LOG_ASSEMBLY();
}
	

#pragma mark - Actor needs

- (void)parser:(PKParser *)parser didMatchObjectNeedsGroup:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSMutableArray *needs = [NSMutableArray array];
	id top;
	while ([(top = [a pop]) isKindOfClass:[AZRActorNeed class]])
		[needs addObject:top];
	
	AZRActorClassDescription *description = top;
	NSAssert([description isKindOfClass:[AZRActorClassDescription class]], @"Failed to attach needs to object: current object isn't an actor");

	[description setNeeds:needs];
	[a push:description];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchNeedName:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *name = [a pop];
	if ([name isKindOfClass:[PKToken class]])
		name = [(PKToken *)name stringValue];
	
	AZRActorNeed *need = [AZRNeedManager getNeedDescription:name];
	[a push:need];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchNeedParameters:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSArray *params = [a pop];
	NSAssert([params count] == 2, @"Need must have exact 2 parameters: yelow zone percentage & red zone percentage");
	AZRActorNeed *need = [a pop];
	[need setWarnValue:[(NSNumber *)params[0] floatValue]];
	[need setCritValue:[(NSNumber *)params[1] floatValue]];
	[a push:need];
	LOG_ASSEMBLY();
}

#pragma mark - Object properties groups

- (void)parser:(PKParser *)parser didMatchObjectPropertiesGroups:(PKAssembly *)a {
	LOG_ASSEMBLY();
	
	NSMutableArray *properties = [NSMutableArray array];
	id top;
	while ([(top = [a pop]) isKindOfClass:[NSArray class]])
		[properties addObjectsFromArray:top];
	
	AZRObjectClassDescription *description = top;
	for (AZRObjectProperty *property in properties) {
    [description addProperty:property];
	}
	[a push:description];
	
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchPropertiesGroup:(PKAssembly *)a {
	LOG_ASSEMBLY();
	
	NSMutableArray *group = [NSMutableArray array];
	AZRObjectProperty *p;
	while ([(p = [a pop]) isKindOfClass:[AZRObjectProperty class]])
		[group addObject:p];
	
	AZRPropertyType type = [(NSNumber *)p integerValue];
	for (AZRObjectProperty *property in group) {
    [property setType:type];
	}
	[a push:group];
	
	LOG_ASSEMBLY();
}

#pragma mark - Object properties

- (void)parser:(PKParser *)parser didMatchPropertyValue:(PKAssembly *)a {
	LOG_ASSEMBLY();
	id value = [a pop];
	AZRObjectProperty *property = [a pop];
	if ([value isKindOfClass:[NSNumber class]])
		[property setNumberValue:value];
	else if ([value isKindOfClass:[NSString class]])
		[property setStringValue:value];
	else if ([value isKindOfClass:[NSArray class]])
		[property setVectorValue:value];
	else;
	
	[a push:property];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchPropertyName:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSString *name = [a pop];
	if ([name isKindOfClass:[PKToken class]])
		name = [(PKToken *)name stringValue];
	AZRObjectProperty *property = [[AZRObjectProperty alloc] initWithName:name];
	[a push:property];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchGroupTag:(PKAssembly *)a {
	LOG_ASSEMBLY();
	NSNumber *type = [a pop];
	id maybePublicity = [a pop];
	if (![maybePublicity isKindOfClass:[NSNumber class]]) {
		[a push:maybePublicity];
		maybePublicity = @(AZRPropertyTypePublic);
	}
	
	type = @([type integerValue] | [(NSNumber *)maybePublicity integerValue]);
	
	[a push:type];
	LOG_ASSEMBLY();
}

- (void)parser:(PKParser *)parser didMatchTagHidden:(PKAssembly *)a {
	[a push:@(AZRPropertyTypeDiscoverable)];
}

- (void)parser:(PKParser *)parser didMatchTagPublic:(PKAssembly *)a {
	[a push:@(AZRPropertyTypePublic)];
}

- (void)parser:(PKParser *)parser didMatchTagProperty:(PKAssembly *)a {
	[a push:@(AZRPropertyTypeProperty)];
}

- (void)parser:(PKParser *)parser didMatchTagAction:(PKAssembly *)a {
	[a push:@(AZRPropertyTypeAction)];
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
	LOG_ASSEMBLY();
	id element;
	NSMutableArray *vector = [NSMutableArray array];
	
	// pushing all till '[' marker
	while (![(element = [a pop]) isKindOfClass:[PKToken class]]) {
		[vector insertObject:element atIndex:0];
	}
	
	// discarding marker
	//	if (number)
	//  	[a push:number];
	
	[a push:[vector copy]];
	LOG_ASSEMBLY();
}

@end

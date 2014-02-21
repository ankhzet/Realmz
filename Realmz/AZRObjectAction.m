//
//  AZRObjectAction.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObjectAction.h"

#import "AZRObject.h"
#import "AZRActionIntent.h"
#import "AZRObjectClassDescription.h"
#import "AZRActor.h"
#import "AZRObject+Actions.h"

typedef BOOL (*AZRActionSelectorSignature)(id receiver, SEL selector, id initiator);

@interface AZRObjectAction () {
	SEL actionSelector;
}

- (BOOL) applyableTo: (AZRObject *) target;

@end

@implementation AZRObjectAction

- (id) initWithName: (NSString *) name {
	if (!(self = [super init]))
		return nil;
	
	self.name = name;
	self.validTargets = [NSMutableSet set];
	
	return self;
}

- (BOOL) aquireDetails {
	[self.validTargets addObject:@"object"];
	
	NSString *action = [[[self.name stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	actionSelector = NSSelectorFromString([NSString stringWithFormat:@"action%@WithInitiator:", action]);
	return !!actionSelector;
}

#pragma mark - Validation

- (BOOL) applyableTo: (AZRObject *) target {
	return [target.classDescription compatibleWith:self.validTargets];
}

#pragma mark - Execution

- (BOOL) executeOn: (AZRObject *)target withInitiator:(AZRActor *)initiator {
	AZRActionSelectorSignature sel = (AZRActionSelectorSignature)[[target class] instanceMethodForSelector:actionSelector];
	
	return [self applyableTo:target] && sel(target, actionSelector, initiator);
}

@end


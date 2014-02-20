//
//  AZRObjectRenderer.m
//  Realmz
//
//  Created by Ankh on 20.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObjectRenderer.h"
#import "AZRObjectClassDescription.h"
#import "AZRActionManager.h"

@implementation AZRObjectRenderer

- (void) render:(AZRObject *)object {

}

- (void) renderInterface:(AZRObject *)object {
	CGFloat dx = 0.f, dy = 0.f;
	for (AZRObjectProperty *property in object.classDescription.publicProperties) {
    if (TEST_BIT(property.type, AZRPropertyTypeAction)) {
			AZRObjectAction *action = [AZRActionManager getAction:property.name];


		}

	}
}

@end

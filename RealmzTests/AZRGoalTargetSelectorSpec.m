//
//  AZRGoalTargetSelectorSpec.m
//  Realmz
//
//  Created by Ankh on 05.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "Kiwi.h"

#import "AZRObjectClassDescription.h"
#import "AZRGoalTargetSelector.h"
#import "AZRGoalTargetSelectorLoader.h"
#import "AZRActorObjectsMemory.h"
#import "AZRObject.h"

SPEC_BEGIN(AZRGoalTargetSelectorSpec)

describe(@"Testing AZRGoalTargetSelector", ^{
	
	/*
	 selector: (*property1 [not *property2, and *property3])
	 
	 [p1, p2, p3] + - + = -
	 [  , p2, p3] - - + = -
	 [p1,   , p3] + + + = +
	 [p1, p2,   ] + - - = -
	 [  ,   , p3] - + + = -
	 [  , p2,   ] - - - = -
	 [p1,   ,   ] + + - = -
	 [  ,   ,   ] - + - = -
	 
	 */
	
	NSString *s1 = @"*property1 (not *property2, and *property3)";
	NSString *s2 = @"* (not *property3 > 0.5)";
	NSString *s3 = @"*property3";
	NSString *s4 = @"* (*property1 < 0.5, *property3 > 0.5 (*property2 < 3))";
	NSString *s5 = @"* (*property1 < 0.5, and *property3 > 0.5 (*property2 < 3))";
	
	AZRGoalTargetSelectorLoader *builder = [AZRGoalTargetSelectorLoader new];
	AZRGoalTargetSelector *selector1 = [builder loadFromString:s1];
	AZRGoalTargetSelector *selector2 = [builder loadFromString:s2];
	AZRGoalTargetSelector *selector3 = [builder loadFromString:s3];
	AZRGoalTargetSelector *selector4 = [builder loadFromString:s4];
	AZRGoalTargetSelector *selector5 = [builder loadFromString:s5];
	
	it(@"should compile selectors", ^{
		[[selector1 shouldNot] beNil];
		[[selector2 shouldNot] beNil];
		[[selector3 shouldNot] beNil];
		[[selector4 shouldNot] beNil];
		[[selector5 shouldNot] beNil];
	});
		
	it(@"should properly match objects", ^{
		AZRObjectClassDescription *description1 = [[AZRObjectClassDescription alloc] initWithName:@"object1"];
		AZRObjectClassDescription *description2 = [[AZRObjectClassDescription alloc] initWithName:@"object2"];
		AZRObjectClassDescription *description3 = [[AZRObjectClassDescription alloc] initWithName:@"object3"];
		AZRObjectClassDescription *description4 = [[AZRObjectClassDescription alloc] initWithName:@"object4"];
		AZRObjectClassDescription *description5 = [[AZRObjectClassDescription alloc] initWithName:@"object5"];
		AZRObjectClassDescription *description6 = [[AZRObjectClassDescription alloc] initWithName:@"object6"];
		AZRObjectClassDescription *description7 = [[AZRObjectClassDescription alloc] initWithName:@"object7"];
		AZRObjectClassDescription *description8 = [[AZRObjectClassDescription alloc] initWithName:@"object8"];
		
		[description1 addProperty:@"property1" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];
		[description1 addProperty:@"property2" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];
		[description1 addProperty:@"property3" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];

		[description2 addProperty:@"property2" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];
		[description2 addProperty:@"property3" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];

		[description3 addProperty:@"property1" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];
		[description3 addProperty:@"property3" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];

		[description4 addProperty:@"property1" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];
		[description4 addProperty:@"property2" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];

		[description5 addProperty:@"property3" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];

		[description6 addProperty:@"property2" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];

		[description7 addProperty:@"property1" withType:AZRPropertyTypePublic | AZRPropertyTypeProperty];


		
		AZRObject *object1 = [description1 instantiateObject];
		AZRObject *object2 = [description2 instantiateObject];
		AZRObject *object3 = [description3 instantiateObject];
		AZRObject *object4 = [description4 instantiateObject];
		AZRObject *object5 = [description5 instantiateObject];
		AZRObject *object6 = [description6 instantiateObject];
		AZRObject *object7 = [description7 instantiateObject];
		AZRObject *object8 = [description8 instantiateObject];
		NSArray *objects = @[object1, object2, object3, object4, object5, object6, object7, object8];
		
		NSLog(@"%@", selector1);
		NSLog(@"%@", selector2);
		NSLog(@"%@", selector3);
		NSLog(@"%@", selector4);
		NSLog(@"%@", selector5);
		
		AZRActorObjectsMemory *fakeMemory = [AZRActorObjectsMemory new];
		for (AZRObject *o in objects) {
			[fakeMemory objectSeen:o];
			for (NSString *p in [o.classDescription publicProperties])
				[fakeMemory property:p discoveredForObject:o];
		}
				
		for (AZRGoalTargetSelector *s in @[selector1, selector2, selector3, selector4, selector5]) {
			NSString *match = @"";
			for (AZRObject *o in objects)
				match = [NSString stringWithFormat:@"%@, %@", match, [s objectMatch:o asKnownBy:fakeMemory] ? @"+" : @"-"];
			
			NSLog(@"selector:\n%@\n[%@]\n\n", s, match);
		}
		/*
		[[theValue([selector1 objectMatch:object1]) should] beNo];
		[[theValue([selector1 objectMatch:object2]) should] beNo];
		[[theValue([selector1 objectMatch:object3]) should] beYes];
		[[theValue([selector1 objectMatch:object4]) should] beNo];
		[[theValue([selector1 objectMatch:object5]) should] beNo];
		[[theValue([selector1 objectMatch:object6]) should] beNo];
		[[theValue([selector1 objectMatch:object7]) should] beNo];
		[[theValue([selector1 objectMatch:object8]) should] beNo];
		 */
	});
	
});

SPEC_END

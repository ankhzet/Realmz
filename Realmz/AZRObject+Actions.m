//
//  AZRObject+Actions.m
//  Realmz
//
//  Created by Ankh on 16.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRObject+Actions.h"
#import "AZRActor.h"
#import "AZRActorNeed.h"
#import "AZRObject+VisibleObject.h"

AZRActorCommonAction const AZRActorCommonActionInspect = @"inspect";
AZRActorCommonAction const AZRActorCommonActionComeTo = @"come-to";

@implementation AZRObject (Actions)

- (BOOL) actionInspectWithInitiator:(AZRActor *)initiator {
	[initiator.knownObjects objectInspected:self];
	
	AZRActorNeed *exitement = [initiator.needs objectForKey:AZRActorNeedExitement];
	float exValue = 0.25 + (arc4random() % 1000) / 2000.0f;
	float newValue = MIN(exitement.currentValue + exValue, 1.0);
	[AZRLogger log:nil withMessage:@"Inspected [%@], %.2f exitement gained...", self.classDescription.name, newValue - exitement.currentValue];
	exitement.currentValue = newValue;
	
	return YES;
}

- (BOOL) actionComeToWithInitiator:(AZRObject *)initiator {
	CGPoint targetPos = [self coordinates];
	CGPoint initiatorPos = [initiator coordinates];
	
	float dx = targetPos.x - initiatorPos.x;
	float dy = targetPos.y - initiatorPos.y;
	
	float len = (dx * dx + dy * dy);
	
	float r1 = [self radius];
	float r2 = [initiator radius];
	
	if (len <= SQR(r1 + r2 * 2)) {
		return YES;
	}
	
	//TODO: proper speed computance
	len = sqrt(len) * 2.f;
	
	initiatorPos.x += dx / len;
	initiatorPos.y += dy / len;
	
	[initiator moveToXY:initiatorPos];
	
	return NO;
}

@end

//
//  AZRRealm.m
//  Realmz
//
//  Created by Ankh on 04.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRRealm.h"

#import "AZRObject.h"
#import "AZRActor.h"
#import "AZRObject+VisibleObject.h"
#import "AZRObjectClassDescriptionManager.h"

@interface AZRRealm ()
{
	NSMutableArray *allObjects;
	NSMutableArray *allActors;
	NSMutableArray *deadObjects;
}
@end

@implementation AZRRealm

+ (AZRRealm *) realm {
	static AZRRealm *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
    instance = [[AZRRealm alloc] initSingletone];
	});
	return instance;
}

- (id) init {
	@throw [NSException exceptionWithName:@"AZRRealmInitError" reason:@"AZRRealm should be instantiated only as singletone" userInfo:nil];
}

- (id) initSingletone {
	if (!(self = [super init]))
		return nil;
	
	self->allObjects = [NSMutableArray array];
	self->allActors = [NSMutableArray array];
	self->deadObjects = [NSMutableArray array];

	return self;
}

- (AZRObject *) spawnObject:(AZRObjectClassDescription *)objectDescriptor {
	AZRObject *instance = [objectDescriptor instantiateObject];
	if (instance)
		[self addObject:instance];
	return instance;
}

- (AZRObject *)spawnObject:(NSString *)objectClassDescription atX:(float)x andY:(float)y {
	AZRObject *object = [self spawnObject:[[AZRObjectClassDescriptionManager getInstance] getDescription:objectClassDescription]];
	[object moveToXY:CGPointMake(x, y)];
	return object;
}

- (void) addObject:(AZRObject *)object {
	[self->allObjects addObject:object];
	if ([object isKindOfClass:[AZRActor class]]) {
		[self->allActors addObject:object];
	}
	object->realm = self;
}

- (NSArray *) allObjects {
	return self->allObjects;
}

- (BOOL) process {
	[self->allActors removeObjectsInArray:self->deadObjects];
	[self->allObjects removeObjectsInArray:self->deadObjects];
	
	BOOL empty = ![self->allObjects count];
	
	if (!empty) {
		NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
		for (AZRActor *actor in self->allActors) {
			if (![actor think:timestamp]) {
				[self->deadObjects addObject:actor];
				[AZRLogger log:nil withMessage:@"[%@] is dead =\\", actor.classDescription.name];
			} else
				empty = NO;
		}

		BOOL updated = YES;
		int maxIterations = 2;
		while (updated && (maxIterations-- > 0)) {
			updated = NO;
			for (AZRObject *o1 in allObjects) {
				float w1 = [o1 weight];
				if (w1 <= 0) continue;

				CGPoint p1 = [o1 coordinates];
				float r1 = [o1 radius];

				for (AZRObject *o2 in allObjects) {
					if (o2 == o1) {
						continue;
					}
					CGPoint p2 = [o2 coordinates];
					float r2 = [o2 radius];
					float dx = p2.x - p1.x;
					float dy = p2.y - p1.y;
					float d = SQR(dx) + SQR(dy);
					float minDist = SQR(r1 + r2);
					float overlap = minDist - d;
					if (overlap < 1.0f)
						continue;


					float w2 = [o2 weight];
					float sumWeight = w1 + w2;

					float f1 = w1 / sumWeight;
					float f2 = w2 / sumWeight;

					float r = sqrt(overlap / minDist);
					float d1 = (w1 > 0) ? r * r2 * f1 : 0.f; // overlap percent * o1 radius * o2 impact
					float d2 = (w2 > 0) ? r * r1 * f2 : 0.f;

					if (!(d1 >= 1 || d2 >= 1))
						continue;

					updated = YES;

					dx /= d;
					dy /= d;
					p1.x -= d1 * dx;
					p1.y -= d1 * dy;

					p2.x += d2 * dx;
					p2.y += d2 * dy;

					[o1 moveToXY:p1];
					[o2 moveToXY:p2];
				}
			}
		}
	}
	
	return !empty;
}

- (NSArray *) inRectOf:(CGRect)rect {
	NSMutableArray *a = [NSMutableArray array];
	for (AZRObject *object in self->allObjects) {
    CGPoint pos = [object coordinates];

		if (CGRectContainsPoint(rect, pos))
			[a addObject:object];
	}

	return a;
}

- (NSArray *) overlapsWith:(CGPoint)center withDistanceOf:(float)distance {
	NSMutableArray *a = [NSMutableArray array];
	for (AZRObject *object in allObjects) {
    CGPoint pos = [object coordinates];
		float radius= [object radius] + distance;
		float d = SQR(center.x - pos.x) + SQR(center.y - pos.y);
		if (d <= SQR(radius))
			[a addObject:object];
	}

	return a;
}

- (NSArray *)inRangeOf:(CGPoint)center withDistanceOf:(float)distance {
	distance *= distance;

	NSMutableArray *a = [NSMutableArray array];
	for (AZRObject *object in self->allObjects) {
    CGPoint pos = [object coordinates];
		float d = SQR(center.x - pos.x) + SQR(center.y - pos.y);
		if (d <= distance)
			[a addObject:object];
	}

	return a;
}

@end

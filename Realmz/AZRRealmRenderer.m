//
//  AZRRealmRenderer.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRRealmRenderer.h"

#import "AZRRealm.h"
#import "AZRObject.h"
#import "AZRObject+VisibleObject.h"
#import "AZRObjectProperty.h"
#import "AZRActor.h"
#import "AZRActorNeed.h"
#import "AZRObjectAction.h"

@interface AZRRealmRenderer () {
	__weak AZRRealm *realm;
	BOOL select;
	CGPoint selStart, selEnd;
}
@end
@implementation AZRRealmRenderer

- (void) attachToRealm:(AZRRealm *)_realm {
	self->realm = _realm;
	[self.selection removeAllObjects];
}

/*
- (id)initWithFrame:(NSRect)frame
{
	if (!(self = [super initWithFrame:frame]))
		return nil;
	
	select = NO;
	self.selection = [NSMutableArray array];
	
	return self;
}

- (void) rightMouseDown:(NSEvent *)event {
	if (![self acceptsControl:@selector(rightClicked:atCoordinates:)])
		return;

	CGPoint tapLocation = [event locationInWindow];
	tapLocation = [self convertPoint:tapLocation fromView:nil];

	NSArray *picked = [self->realm overlapsWith:tapLocation withDistanceOf:5.f];
	[self.delegate rightClicked:picked atCoordinates:tapLocation];
}

- (void) mouseDown:(NSEvent *)event {
	CGPoint tapLocation = [event locationInWindow];
	tapLocation = [self convertPoint:tapLocation fromView:nil];
	
	NSArray *picked = [self->realm overlapsWith:tapLocation withDistanceOf:5.f];
	select = ![picked count];
	selStart = NSMakePoint((int)tapLocation.x, (int)tapLocation.y);
	selEnd = selStart;

	[self.selection removeAllObjects];
	if (!select) {
		[self.selection addObject:picked[0]];
	}
}

- (BOOL) acceptsControl:(SEL)selector {
	return self.delegate && [self.delegate respondsToSelector:selector];
}

- (void) mouseUp:(NSEvent *)event {
	[self mouseDragged:event];
	select = NO;
}

- (void) mouseDragged:(NSEvent *)event {
	if (!(select || [self.selection count])) {
		return;
	}

	CGPoint tapLocation = [event locationInWindow];
	tapLocation = [self convertPoint:tapLocation fromView:nil];

	BOOL onePicked = [self.selection count] == 1;
	if (onePicked && !select) {
		if (([event modifierFlags] & NSControlKeyMask) == NSControlKeyMask) {
			[self.selection[0] moveToXY:tapLocation];
		}
		return;
	}

	selEnd = tapLocation;
	CGFloat x = MIN(selStart.x, selEnd.x);
	CGFloat y = MIN(selStart.y, selEnd.y);
	CGFloat w = ABS(selStart.x - selEnd.x);
	CGFloat h = ABS(selStart.y - selEnd.y);
	NSArray *inRectObjects = [realm inRectOf:NSMakeRect(x, y, w, h)];
	if ([inRectObjects count] > 0) {
		inRectObjects = [inRectObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSUInteger d1 = ((AZRObject *)obj1).classDescription.multiSelectionGroup;
			NSUInteger d2 = ((AZRObject *)obj2).classDescription.multiSelectionGroup;
			return (d1 > d2) ? NSOrderedAscending : ((d1 < d2) ? NSOrderedDescending : NSOrderedSame);
		}];

		NSUInteger preferGroup = ((AZRObject *)inRectObjects[0]).classDescription.multiSelectionGroup;

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"classDescription.multiSelectionGroup = %lu", preferGroup];

		self.selection = [[inRectObjects filteredArrayUsingPredicate:predicate] mutableCopy];
	} else
		[self.selection removeAllObjects];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	[[NSColor whiteColor] setStroke];
	[[NSColor lightGrayColor] setFill];
	
	NSBezierPath* drawingPath = [NSBezierPath bezierPath];
	NSBezierPath* viewSightPath = [NSBezierPath bezierPath];
	
	NSRect frame = NSInsetRect(dirtyRect, 2, 2);
	[drawingPath appendBezierPathWithRect: frame];
	[drawingPath stroke];
	[drawingPath fill];
	[drawingPath removeAllPoints];
	
	NSTimeInterval i = [NSDate timeIntervalSinceReferenceDate];
	
	Class isActor = [AZRActor class];
	NSNumber *bYes = @(YES);
	NSNumber *bNo = @(NO);
	NSDictionary *textAttr = [@{NSForegroundColorAttributeName: [NSColor blackColor]} mutableCopy];
	
	for (AZRObject *o in [self->realm allObjects]) {
//		BOOL isActor = [o isKindOfClass:[AZRActor class]];
		float radius = [o radius];
		CGPoint pos = [o coordinates];
		frame = NSMakeRect(pos.x - radius, pos.y - radius, radius * 2, radius * 2);
		[drawingPath appendBezierPathWithOvalInRect:frame];
		
//		NSString *name = o.description.name;
//		NSSize textBox = [name sizeWithAttributes:nil];
		
//		CGFloat cx = pos.x - textBox.width / 2;
//		CGFloat cy = pos.y - textBox.height - radius;
//		[name drawAtPoint:NSMakePoint(cx, cy) withAttributes:nil];
		
		AZRObjectAction *action = o.performedAction;
		if (action) {
			NSString *name = action.name;
			NSSize textBox = [name sizeWithAttributes:nil];
			
			CGFloat cx = pos.x - textBox.width / 2;
			CGFloat cy = pos.y - textBox.height * 2 + radius;
			[name drawAtPoint:NSMakePoint(cx, cy) withAttributes:nil];
		}
		
//		if (isActor) {
//			float view = [[o.description valueForKey:@"viewSight"] floatValue];
//			frame = NSMakeRect(pos.x - view, pos.y - view, view * 2, view * 2);
//			[viewSightPath appendBezierPathWithOvalInRect:frame];
//		}
	}

	[[NSColor whiteColor] setStroke];
	[viewSightPath stroke];
	
	[[NSColor blackColor] setStroke];
	[drawingPath stroke];
	[drawingPath removeAllPoints];

	if ([self.selection count]) {
		for (AZRObject *selected in self.selection) {
			CGPoint pos = [selected coordinates];
			float radius = MAX(5, [selected radius]);
			frame = NSMakeRect(pos.x - radius, pos.y - radius, radius * 2, radius * 2);
			[drawingPath appendBezierPathWithOvalInRect:frame];

			if ([selected isKindOfClass:isActor]) {
				NSDictionary *needs = [(AZRActor *)selected pickImportantNeeds];
				NSArray *critical = needs[bYes];
				NSArray *normal = needs[bNo];

				NSString *c = @"";
				for (AZRActorNeed *need in critical) {
					c = [NSString stringWithFormat:@"%@\n%@!", c, need.name];
				}
				for (AZRActorNeed *need in normal) {
					c = [NSString stringWithFormat:@"%@\n%@", c, need.name];
				}
				NSSize textBox = [c sizeWithAttributes:nil];

				CGFloat cx = pos.x - textBox.width / 2;
				CGFloat cy = pos.y + radius;

				[c drawAtPoint:NSMakePoint(cx, cy) withAttributes:textAttr];
			}
		}
		[[NSColor blueColor] setFill];
		[drawingPath fill];
		[drawingPath removeAllPoints];
	}

	if (select) {
		CGFloat x = (int)MIN(selStart.x, selEnd.x);
		CGFloat y = (int)MIN(selStart.y, selEnd.y);
		CGFloat w = (int)ABS(selStart.x - selEnd.x);
		CGFloat h = (int)ABS(selStart.y - selEnd.y);
		[drawingPath appendBezierPathWithRect:NSMakeRect(x + 1, y - 1, w, h)];
		[[NSColor darkGrayColor] setStroke];
		float linew = [drawingPath lineWidth];
		[drawingPath setLineWidth:1.f];
		[drawingPath stroke];
		[drawingPath removeAllPoints];
		[drawingPath appendBezierPathWithRect:NSMakeRect(x, y, w, h)];
		[[NSColor greenColor] setStroke];
		[drawingPath stroke];
		[drawingPath stroke];
		[drawingPath stroke];
		[drawingPath setLineWidth:linew];
		[drawingPath removeAllPoints];
	}

	i = [NSDate timeIntervalSinceReferenceDate] - i;
	
	{
		NSString *label = [NSString stringWithFormat:@"Objects: %lu", (unsigned long)[[self->realm allObjects] count]];
		NSSize textBox = [label sizeWithAttributes:nil];
		
		CGFloat x = self.bounds.size.width - textBox.width - 2 - 5;
		CGFloat y = textBox.height / 2 - 2;
		
		[self outText:label atX:x andY:y];
	}
	
	{
		NSString *label = [NSString stringWithFormat:@"FPS: %.2f", fps];
		NSSize textBox = [label sizeWithAttributes:nil];
		
		CGFloat x = self.bounds.size.width - textBox.width - 2 - 5;
		CGFloat y = textBox.height / 2 - 2 + textBox.height;
		[self outText:label atX:x andY:y];
	}
	
	[self calcFPSWithNewFrame];
}

- (void) outText:(NSString *)text atX:(float)x andY:(float)y {
	NSDictionary *textAttr = [@{NSForegroundColorAttributeName: [NSColor blackColor]} mutableCopy];
	[text drawAtPoint:NSMakePoint(x - 1, y - 1) withAttributes:textAttr];
	[text drawAtPoint:NSMakePoint(x - 1, y + 1) withAttributes:textAttr];
	[text drawAtPoint:NSMakePoint(x + 1, y - 1) withAttributes:textAttr];
	[text drawAtPoint:NSMakePoint(x + 1, y + 1) withAttributes:textAttr];
	[textAttr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[text drawAtPoint:NSMakePoint(x, y) withAttributes:textAttr];
}
*/

@end

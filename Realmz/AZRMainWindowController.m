//
//  AZRMainWindowController.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMainWindowController.h"

#import "AZRRealm.h"
#import "AZRObjectClassDescriptionManager.h"
#import "AZRObject.h"
#import "AZRObject+VisibleObject.h"
#import "AZRActor.h"
#import "AZRActorBrain.h"
#import "AZRActorNeed.h"

#import "AZRRealmRenderer.h"

@interface AZRMainWindowController () <AZRRealmRendererControlDelegate> {
	__strong NSTimer *processTimer;
	BOOL simulating;
	AZRRealm *realm;
}

@property (weak) IBOutlet AZRRealmRenderer *realmRenderer;
@property (weak) IBOutlet UIView *panelView;
@property (strong) IBOutlet UIView *actionPanel;
@property (weak) IBOutlet UITableView *needsTableView;

@property (nonatomic) AZRObject *object;
@property (nonatomic) NSMutableArray *needs;

- (IBAction)actionSpawn:(id)sender;
- (IBAction)actionMakeOrder:(id)sender;

@end

@implementation AZRMainWindowController

/*
- (id)initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (!self) {
		return self;
	}
	
	self->realm = [AZRRealm new];
	
	self->simulating = NO;
	
	self->processTimer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(processTick:) userInfo:nil repeats:YES];
	if (self->processTimer)
		[[NSRunLoop currentRunLoop] addTimer:self->processTimer forMode:NSDefaultRunLoopMode];
	
	return self;
}

- (void) dealloc {
	[self->processTimer invalidate];
	self->processTimer = nil;
	self->realm = nil;
}

- (void) setWindow:(NSWindow *)window {
	[super setWindow:window];
	
	[[NSBundle mainBundle] loadNibNamed:@"ActionPanel" owner:self topLevelObjects:nil];
	[self.actionPanel setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
	[self.actionPanel setFrameSize:self.panelView.frame.size];
	[self.panelView addSubview:self.actionPanel];

	[self.realmRenderer attachToRealm:self->realm];
	self.realmRenderer.delegate = self;
	
	int w = (int)((NSView *)self.window.contentView).frame.size.width - 20.f;
	int h = (int)((NSView *)self.window.contentView).frame.size.height - 20.f;
	NSString *environment[] = {@"tree"};
	size_t s = sizeof(environment) / sizeof(NSString*);
	for (int i = 0; i < 100; i ++) {
		float x = (arc4random() % w) + 10.f;
		float y = (arc4random() % h) + 10.f;
		[self->realm spawnObject:environment[arc4random() % s] atX:x andY:y];
	}
	[self->realm spawnObject:@"storage" atX:w/3 andY:h/2];
	[self->realm spawnObject:@"village" atX:2*w/3 andY:h/2];

	simulating = YES;
}

- (void) processTick:(NSTimer *)timer {
//	NSLog(@"Tick");

	[self.realmRenderer setNeedsDisplay:YES];

	if (!self->simulating)
		return;
	
	if (![self->realm process]) {
		[AZRLogger log:nil withMessage:@"Realm is empty"];
		self->simulating = NO;
	}

	self.needs = nil;
	BOOL oneSelected = [self.realmRenderer.selection count] == 1;
	if (oneSelected) {
		self.object = self.realmRenderer.selection[0];
	
		NSMutableArray *data = [NSMutableArray array];
		if ([self.object isKindOfClass:[AZRActor class]]) {
			for (AZRActorNeed *need in [((AZRActor *)self.object).needs allValues]) {
				[data addObject:@{@"name":need.name, @"value": [NSString stringWithFormat:@"%.2f", need.currentValue]}];
			}
		}

		for (AZRObjectProperty *p in [self.object.properties allValues]) {
			NSString *value = [[[[[[p description]
													stringByReplacingOccurrencesOfString:@"\n" withString:@""]
												 stringByReplacingOccurrencesOfString:p.name withString:@""]
												 stringByReplacingOccurrencesOfString:@":" withString:@""]
												 stringByReplacingOccurrencesOfString:@" " withString:@""]
												 stringByReplacingOccurrencesOfString:@"*" withString:@""];
			[data addObject:@{@"name": p.name, @"value": value}];
		}
		self.needs = data;
	}
}
*/

- (IBAction)actionSpawn:(id)sender {
	AZRActor *actor;
	for (int i = 0; i < 10; i++) {
		int w = (int)self.realmRenderer.frame.size.width - 20;
		int h = (int)self.realmRenderer.frame.size.height - 20;
		float x = arc4random() % w + 10;
		float y = arc4random() % h + 10;
		actor = (AZRActor *)[self->realm spawnObject:@"peasant" atX:x andY:y];
	}
//	NSLog(@"%@", actor->brain.goal);
	
	self.object = actor;
	self->simulating = YES;
}

- (IBAction)actionMakeOrder:(id)sender {
	for (AZRObject *object in self.realmRenderer.selection) {
		if ([object isKindOfClass:[AZRActor class]]) {
			[(AZRActor *)object scheduleGoal:@"gain-wood" imperative:YES];
		}
	}
}

- (void) rightClicked:(NSArray *)underClickObjects atCoordinates:(CGPoint)coordinates {
	if (![self.realmRenderer.selection count])
		return;

	AZRObject *checkPoint = [realm spawnObject:@"move-point" atX:coordinates.x andY:coordinates.y];
	int inTheWay = 0;
	for (AZRObject *o in self.realmRenderer.selection)
		if ([o isKindOfClass:[AZRActor class]]) {
			AZRActor *actor = (AZRActor *)o;
			[actor scheduleGoal:@"move-to" targetedAt:[NSValue valueWithCGPoint:coordinates] imperative:YES];
			[actor.knownObjects objectInspected:checkPoint];
			inTheWay++;
	  }

	[checkPoint floatPropertyIncrease:@"in-process" withValue:inTheWay];

	NSLog(@"%@", underClickObjects);
}

@end

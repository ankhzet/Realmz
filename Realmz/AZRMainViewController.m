//
//  AZRMainWindowController.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMainViewController.h"

#import "AZRRealm.h"
#import "AZRRealmRenderer.h"

static BOOL isRunningTests(void) __attribute__((const));


@interface AZRMainViewController ()
{
	__strong NSTimer *processTimer;
	BOOL simulating;
	AZRRealm *realm;
}

@property (nonatomic) AZRRealmRenderer *realmRenderer;

@end

@implementation AZRMainViewController

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (isRunningTests()) {
		return;
	}

	simulating = NO;

	// Configure the view.
	SKView *skView = (SKView *)self.view;
	if (skView.scene)
		return;

	skView.showsFPS = YES;
	skView.showsNodeCount = YES;

	self.realmRenderer = [AZRRealmRenderer sceneWithSize:skView.bounds.size];
	self.realmRenderer.scaleMode = SKSceneScaleModeAspectFill;

	realm = [AZRRealm realm];

	[self.realmRenderer attachToRealm:realm];

	[skView presentScene:self.realmRenderer];

	simulating = YES;

	processTimer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(processTick:) userInfo:nil repeats:YES];
	if (processTimer)
		[[NSRunLoop currentRunLoop] addTimer:processTimer forMode:NSDefaultRunLoopMode];

	[self.realmRenderer processed:[NSDate timeIntervalSinceReferenceDate]];
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskAllButUpsideDown;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void) dealloc {
	[self->processTimer invalidate];
	self->processTimer = nil;
	self->realm = nil;
}


- (void) processTick:(NSTimer *)timer {
	if (!simulating)
		return;

	if (![realm process]) {
		[AZRLogger log:nil withMessage:@"Realm is empty"];
		simulating = NO;
	}

	[self.realmRenderer processed:[NSDate timeIntervalSinceReferenceDate]];
}

}

@end

static BOOL isRunningTests(void) {
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
	NSString* injectBundle = environment[@"XCInjectBundle"];
	return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
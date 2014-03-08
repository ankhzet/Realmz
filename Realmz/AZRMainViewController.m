//
//  AZRMainWindowController.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMainViewController.h"

#import "AZRGame.h"
#import "AZRRealm.h"
#import "AZRGameScene.h"
#import "AZRPlayer.h"
#import "AZRPlayerState.h"
#import "AZRInGameResourceManager.h"

static BOOL isRunningTests(void) __attribute__((const));


@interface AZRMainViewController ()
{
	__strong NSTimer *processTimer;
	BOOL simulating;
}

@property (nonatomic) AZRGame *game;
@property (nonatomic) AZRGameScene *gameScene;

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

	self.game = [AZRGame game];
	[self.game loadMapNamed:@"map01"];

	AZRPlayerState *playerState = [self.game getHumanPlayer].state;
	[playerState.resourcesManager resourceNamed:@"wood" addAmount:500];
	[playerState.resourcesManager resourceNamed:@"gold" addAmount:500];
	[playerState.resourcesManager resourceNamed:@"stone" addAmount:500];
	[playerState.resourcesManager resourceNamed:@"food" addAmount:500];

	self.gameScene = [AZRGameScene sceneForGame:self.game withSize:skView.bounds.size];
	self.gameScene.scaleMode = SKSceneScaleModeAspectFill;

	[skView presentScene:self.gameScene];

	simulating = YES;

	processTimer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(processTick:) userInfo:nil repeats:YES];
	if (processTimer)
		[[NSRunLoop currentRunLoop] addTimer:processTimer forMode:NSDefaultRunLoopMode];

	[self.gameScene process:[NSDate timeIntervalSinceReferenceDate]];
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
	self.gameScene = nil;
	self.game = nil;
}


- (void) processTick:(NSTimer *)timer {
	if (!simulating)
		return;

	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];

	[self.game process:currentTime];
	[self.gameScene process:currentTime];
}

- (IBAction)actionMakeOrder:(id)sender {
}

- (void) rightClicked:(NSArray *)underClickObjects atCoordinates:(CGPoint)coordinates {
}

@end

static BOOL isRunningTests(void) {
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
	NSString* injectBundle = environment[@"XCInjectBundle"];
	return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
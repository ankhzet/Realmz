//
//  AZRMainWindowController.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMainViewController.h"

static BOOL isRunningTests(void) __attribute__((const));

@interface AZRMainViewController () <AZRRealmRendererControlDelegate> {
}

@end

@implementation AZRMainViewController

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (isRunningTests()) {
		return;
	}

	// Configure the view.
	SKView *skView = (SKView *)self.view;
	if (skView.scene)
		return;

	skView.showsFPS = YES;
	skView.showsNodeCount = YES;
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

}

@end

static BOOL isRunningTests(void) {
	NSDictionary* environment = [[NSProcessInfo processInfo] environment];
	NSString* injectBundle = environment[@"XCInjectBundle"];
	return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
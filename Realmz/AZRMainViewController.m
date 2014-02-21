//
//  AZRMainWindowController.m
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import "AZRMainViewController.h"

@interface AZRMainViewController () <AZRRealmRendererControlDelegate> {
}

@end

@implementation AZRMainViewController

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	// Configure the view.
	SKView *skView = (SKView *)self.view;
	if (skView.scene)
		return;

	skView.showsFPS = YES;
	skView.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskAllButUpsideDown;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

@end

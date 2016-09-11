/*
 * FlipsideViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright VSO-Software 2009. All rights reserved.
 */

#import "VSOSettingsViewController.h"

#import "Constants.h"
#import "VSOUtils.h"

#import "VSOLevelSizeViewController.h"
#import "VSOLevelDifficultyViewController.h"
#import "VSOChallengeShapeViewController.h"
#import "VSOPlayingModeViewController.h"



@implementation VSOSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]) != nil) {
		self.title = @"GPS Body Paint";
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self refreshUI];
}

/* Ugly, isn't it? */
- (void)doDismissModalViewControllerAnimated
{
	NSDLog(@"doDismissModalViewControllerAnimated called");
	
	if (![self modalViewController]) return;
	[self dismissModalViewControllerAnimated:YES];
	[self performSelector:@selector(doDismissModalViewControllerAnimated) withObject:nil afterDelay:0.15];
}

- (void)playViewControllerDidFinish:(VSOPlayViewController *)controller
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[self doDismissModalViewControllerAnimated];
}

- (IBAction)play:(id)sender
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	VSOPlayViewController *controller = [[VSOPlayViewController alloc] initWithNibName:@"VSOPlayView" bundle:nil];
	
	settings.gameShape = [NSKeyedUnarchiver unarchiveObjectWithData:[ud valueForKey:VSO_UDK_GAME_SHAPE]];
	settings.playgroundSize = [ud integerForKey:VSO_UDK_LEVEL_SIZE];
	settings.gridSize = 3.;
	settings.playingMode = [ud integerForKey:VSO_UDK_PLAYING_MODE];
	settings.playingTime = [ud doubleForKey:VSO_UDK_PLAYING_TIME];
	settings.playingFillPercentToDo = [ud integerForKey:VSO_UDK_PLAYING_FILL_PERCENTAGE];
	settings.userLocationDiameter = 10. - [ud integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]*1.9;
	
	controller.gameProgress = [[VSOGameProgress alloc] initWithSettings:settings];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - Private

- (void)refreshUI
{
	self.labelLevelSize.text = VSOLevelSizeViewController.localizedSettingValue;
	self.labelLevelDifficulty.text = VSOLevelDifficultyViewController.localizedSettingValue;
	self.labelChallengeShape.text = VSOChallengeShapeViewController.localizedSettingValue;
	self.labelPlayingMode.text = VSOPlayingModeViewController.localizedSettingValue;
}

@end

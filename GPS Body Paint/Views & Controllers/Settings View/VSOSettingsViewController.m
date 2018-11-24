/*
 * FlipsideViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright VSO-Software 2009. All rights reserved.
 */

#import "VSOSettingsViewController.h"

#import "GPS_Body_Paint-Swift.h"

#import "Constants.h"

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	
	if ([segue.identifier isEqualToString:@"Play"]) {
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		VSOPlayViewController *controller = segue.destinationViewController;
		
		self.settings.gameShape = [NSKeyedUnarchiver unarchiveObjectWithData:[ud valueForKey:VSO_UDK_GAME_SHAPE]];
		self.settings.playgroundSize = [ud integerForKey:VSO_UDK_LEVEL_SIZE];
		self.settings.gridSize = 3.;
		self.settings.playingMode = [ud integerForKey:VSO_UDK_PLAYING_MODE];
		self.settings.playingTime = [ud doubleForKey:VSO_UDK_PLAYING_TIME];
		self.settings.playingFillPercentToDo = [ud integerForKey:VSO_UDK_PLAYING_FILL_PERCENTAGE];
		self.settings.userLocationDiameter = 10. - [ud integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]*1.9;
		
		controller.gameProgress = [[GameProgress alloc] initWithSettings:self.settings];
		controller.delegate = self;
	}
}

/* Ugly, isn't it? */
- (void)doDismissModalViewControllerAnimated
{
//	NSLog(@"doDismissModalViewControllerAnimated called");
	
	if ([self presentedViewController] == nil) return;
	[self dismissViewControllerAnimated:YES completion:NULL];
	[self performSelector:@selector(doDismissModalViewControllerAnimated) withObject:nil afterDelay:0.15];
}

- (void)playViewControllerDidFinish:(VSOPlayViewController *)controller
{
	[self doDismissModalViewControllerAnimated];
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

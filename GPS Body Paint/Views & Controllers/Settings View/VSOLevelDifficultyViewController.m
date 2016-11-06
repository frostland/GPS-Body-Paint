/*
 * VSOLevelDifficultyViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import "VSOLevelDifficultyViewController.h"

#import "Constants.h"



@implementation VSOLevelDifficultyViewController

+ (NSString *)localizedSettingValue
{
	NSString *str = [NSString string];
	
	/*switch ([NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_DIFFICULTY]) {
		case 0: str = [str stringByAppendingString:NSLocalizedString(@"big",    nil)]; break;
		case 1: str = [str stringByAppendingString:NSLocalizedString(@"medium", nil)]; break;
		case 2: str = [str stringByAppendingString:NSLocalizedString(@"small",  nil)]; break;
		default: [NSException raise:@"Unknown grid size" format:@"The grid size with id %ld is not valid", (long)[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_DIFFICULTY]];
	}
	str = [str stringByAppendingString:@"/"];*/
	switch ([NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]) {
		case 0: str = [str stringByAppendingString:NSLocalizedString(@"big", nil)]; break;
		case 1: str = [str stringByAppendingString:NSLocalizedString(@"medium", nil)]; break;
		case 2: str = [str stringByAppendingString:NSLocalizedString(@"small", nil)]; break;
		default: [NSException raise:@"Unknown level painting size" format:@"The level painting size with id %ld is not valid", (long)[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]];
	}
	
	return str;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	/*	[self.segmentedControlChosenGridSize setSelectedSegmentIndex:[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_DIFFICULTY]];*/
	[self.segmentedControlChosenPaintingSize setSelectedSegmentIndex:[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]];
}

/*- (IBAction)gridSizeChanged:(UISegmentedControl *)sender
{
	[NSUserDefaults.standardUserDefaults setInteger:sender.selectedSegmentIndex forKey:VSO_UDK_LEVEL_DIFFICULTY];
}*/

- (IBAction)levelPaintingSizeChanged:(UISegmentedControl *)sender
{
	[NSUserDefaults.standardUserDefaults setInteger:sender.selectedSegmentIndex forKey:VSO_UDK_LEVEL_PAINTING_SIZE];
}

@end

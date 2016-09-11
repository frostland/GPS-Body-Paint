/*
 * VSOChallengeShapeViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import "VSOChallengeShapeViewController.h"



@implementation VSOChallengeShapeViewController

+ (NSString *)localizedSettingValue
{
	switch ([[NSKeyedUnarchiver unarchiveObjectWithData:[NSUserDefaults.standardUserDefaults valueForKey:VSO_UDK_GAME_SHAPE]] shapeType]) {
		case 0: return NSLocalizedString(@"square", nil); break;
		case 1: return NSLocalizedString(@"hexagon", nil); break;
		case 2: return NSLocalizedString(@"triangle", nil); break;
		default: [NSException raise:@"Unknown challenge shape" format:@"The shape with id %ld is not a valid shape", (long)[[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_GAME_SHAPE]];
	}
	return @"";
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	shape = [NSKeyedUnarchiver unarchiveObjectWithData:[NSUserDefaults.standardUserDefaults valueForKey:VSO_UDK_GAME_SHAPE]];
	[self.segmentedControlChosenShape setSelectedSegmentIndex:shape.shapeType];
	
	[self.shapeView setGameShape:shape];
}

- (IBAction)shapeChanged:(UISegmentedControl *)sender
{
	shape.shapeType = (VSOGameShapeType)sender.selectedSegmentIndex;
	[NSUserDefaults.standardUserDefaults setValue:[NSKeyedArchiver archivedDataWithRootObject:shape] forKey:VSO_UDK_GAME_SHAPE];
	
	[self.shapeView setNeedsDisplay];
}

@end

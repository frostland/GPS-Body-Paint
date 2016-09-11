//
//  GPSBodyPaintAppDelegate.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/15/09.
//  Copyright VSO-Software 2009. All rights reserved.
//

#import "GPSBodyPaintAppDelegate.h"

#import "VSOSettings.h"
#import "VSOSettingsViewController.h"

#import "Constants.h"

@implementation GPSBodyPaintAppDelegate

@synthesize window;
@synthesize navigationController;

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:VSO_UDK_FIRST_LAUNCH];
	[defaultValues setValue:[NSKeyedArchiver archivedDataWithRootObject:[VSOGameShape gameShapeWithType:VSOGameShapeTypeSquare]] forKey:VSO_UDK_GAME_SHAPE];
	[defaultValues setValue:[NSNumber numberWithInt:1] forKey:VSO_UDK_LEVEL_PAINTING_SIZE];
	[defaultValues setValue:[NSNumber numberWithInt:25] forKey:VSO_UDK_LEVEL_SIZE];
	[defaultValues setValue:[NSNumber numberWithInt:VSOPlayingModeFillIn] forKey:VSO_UDK_PLAYING_MODE];
	[defaultValues setValue:[NSNumber numberWithDouble:5.*60.] forKey:VSO_UDK_PLAYING_TIME];
	[defaultValues setValue:[NSNumber numberWithInt:75] forKey:VSO_UDK_PLAYING_FILL_PERCENTAGE];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
/*	VSOSettingsViewController *aController = [[VSOSettingsViewController alloc] initWithNibName:@"VSOSettingsView" bundle:nil];
	aController.title = NSLocalizedString(@"GPS Body Paint", @"Application title");
	aController.settings = [[VSOSettings new] autorelease];
	navigationController = [[UINavigationController alloc] initWithRootViewController:aController];
	navigationController.delegate = aController;
	
	window.rootViewController = navigationController;
	[window makeKeyAndVisible];
	
	[aController release];*/
	[window makeKeyAndVisible];
}

@end

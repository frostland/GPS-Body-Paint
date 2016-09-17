/*
 * GPSBodyPaintAppDelegate.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright VSO-Software 2009. All rights reserved.
 */

#import "GPSBodyPaintAppDelegate.h"

#import "VSOSettings.h"
#import "VSOSettingsViewController.h"

#import "Constants.h"



@implementation GPSBodyPaintAppDelegate

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setValue:@YES                    forKey:VSO_UDK_FIRST_LAUNCH];
	[defaultValues setValue:@1                      forKey:VSO_UDK_LEVEL_PAINTING_SIZE];
	[defaultValues setValue:@25                     forKey:VSO_UDK_LEVEL_SIZE];
	[defaultValues setValue:@(VSOPlayingModeFillIn) forKey:VSO_UDK_PLAYING_MODE];
	[defaultValues setValue:@(5.*60.)               forKey:VSO_UDK_PLAYING_TIME];
	[defaultValues setValue:@75                     forKey:VSO_UDK_PLAYING_FILL_PERCENTAGE];
	[defaultValues setValue:[NSKeyedArchiver archivedDataWithRootObject:[VSOGameShape gameShapeWithType:VSOGameShapeTypeSquare]] forKey:VSO_UDK_GAME_SHAPE];
	
	[NSUserDefaults.standardUserDefaults registerDefaults:defaultValues];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	((VSOSettingsViewController *)((UINavigationController *)self.window.rootViewController).viewControllers.firstObject).settings = [VSOSettings new];
}

@end

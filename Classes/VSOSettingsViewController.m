//
//  FlipsideViewController.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/15/09.
//  Copyright VSO-Software 2009. All rights reserved.
//

#import "VSOSettingsViewController.h"

#import "Constants.h"
#import "VSOUtils.h"

@implementation VSOSettingViewController

+ (NSString *)settingName
{
	[NSException raise:@"Abstract class method used" format:@"The class VSOSettingViewController is abstract. Do not use it."];
	return nil;
}

+ (NSString *)readableSettingValue
{
	[NSException raise:@"Abstract class method used" format:@"The class VSOSettingViewController is abstract. Do not use it."];
	return nil;
}

@end

/********************************************************************************************************/
@implementation VSOChallengeShapeView

+ (NSString *)settingName
{
	return NSLocalizedString(@"challenge shape", @"challenge shape setting title");
}

+ (NSString *)readableSettingValue
{
	switch ([[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:VSO_UDK_GAME_SHAPE]] shapeType]) {
		case 0: return NSLocalizedString(@"square", nil); break;
		case 1: return NSLocalizedString(@"hexagon", nil); break;
		case 2: return NSLocalizedString(@"triangle", nil); break;
		default: [NSException raise:@"Unknown challenge shape" format:@"The shape with id %d is not a valid shape", [[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_GAME_SHAPE]];
	}
	return @"";
}

- (void)viewDidLoad
{
	shape = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:VSO_UDK_GAME_SHAPE]] retain];
	[segmentedControlChosenShape setSelectedSegmentIndex:shape.shapeType];
	
	[shapeView setGameShape:shape];
}

- (IBAction)shapeChanged:(id)sender
{
	shape.shapeType = [sender selectedSegmentIndex];
	[[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:shape] forKey:VSO_UDK_GAME_SHAPE];
	
	[shapeView setNeedsDisplay];
}

- (void)dealloc
{
	[shape release];
	
	[super dealloc];
}


@end

/********************************************************************************************************/
@implementation VSOLevelDifficultyView

+ (NSString *)settingName
{
	return NSLocalizedString(@"painting size", @"Painting size setting title");
}

+ (NSString *)readableSettingValue
{
	NSString *str = [NSString string];
	
	/*switch ([[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_DIFFICULTY]) {
		case 0: str = [str stringByAppendingString:NSLocalizedString(@"big", nil)]; break;
		case 1: str = [str stringByAppendingString:NSLocalizedString(@"medium", nil)]; break;
		case 2: str = [str stringByAppendingString:NSLocalizedString(@"small", nil)]; break;
		default: [NSException raise:@"Unknown grid size" format:@"The grid size with id %d is not valid", [[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_DIFFICULTY]];
	}
	str = [str stringByAppendingString:@"/"];*/
	switch ([[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]) {
		case 0: str = [str stringByAppendingString:NSLocalizedString(@"big", nil)]; break;
		case 1: str = [str stringByAppendingString:NSLocalizedString(@"medium", nil)]; break;
		case 2: str = [str stringByAppendingString:NSLocalizedString(@"small", nil)]; break;
		default: [NSException raise:@"Unknown level painting size" format:@"The level painting size with id %d is not valid", [[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]];
	}
	
	return str;
}

- (void)viewDidLoad
{
/*	[segmentedControlChosenGridSize setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_DIFFICULTY]];*/
	[segmentedControlChosenPaintingSize setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]];
}
/*
- (IBAction)gridSizeChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:VSO_UDK_LEVEL_DIFFICULTY];
}
*/
- (IBAction)levelPaintingSizeChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:VSO_UDK_LEVEL_PAINTING_SIZE];
}

@end

/********************************************************************************************************/
@implementation VSOLevelSizeView

+ (NSString *)settingName
{
	return NSLocalizedString(@"level size", @"Level size setting title");
}

+ (NSString *)readableSettingValue
{
	return [NSString stringWithFormat:NSLocalizedString(@"n meters format", nil), [[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_SIZE]];
}

- (void)viewDidLoad
{
	NSUInteger s = [[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_SIZE];
	NSUInteger r = 0;
	switch (s) {
		case 25: r = 0; break;
		case 50: r = 1; break;
		case 75: r = 2; break;
	}
	
	[pickerView selectRow:r inComponent:0 animated:NO];
}

- (NSUInteger)nMetersFromPickerRow:(NSUInteger)row
{
	NSUInteger s = 0;
	switch (row) {
		case 0: s = 25; break;
		case 1: s = 50; break;
		case 2: s = 75; break;
		default: [NSException raise:@"Unknown row in pickerView" format:@"The row %d is not valid for the level size setting", row];
	}
	
	return s;
}

/* Datasource */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 3;
}

/* Delegate */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[[NSUserDefaults standardUserDefaults] setInteger:[self nMetersFromPickerRow:row] forKey:VSO_UDK_LEVEL_SIZE];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [NSString stringWithFormat:NSLocalizedString(@"n meters format", nil), [self nMetersFromPickerRow:row]];
}

@end

/********************************************************************************************************/
@implementation VSOPlayingModeView

+ (NSString *)settingName
{
	return NSLocalizedString(@"playing mode", @"Playing mode setting title");
}

+ (NSString *)playingModeStringFromInt:(NSUInteger)m
{
	switch (m) {
		case 0: return NSLocalizedString(@"fill in", @"Fill in play mode setting label"); break;
		case 1: return NSLocalizedString(@"time limit", @"Time limit play mode setting label"); break;
		default: [NSException raise:@"Unknown indexPath in tableView" format:@"The indexPath %d is not valid for the playing mode setting", m];
	}
	
	return @"";
}

+ (NSString *)readableSettingValue
{
	return [self playingModeStringFromInt:[[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_PLAYING_MODE]];
}

- (void)viewDidLoad
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[datePicker setCountDownDuration:[ud doubleForKey:VSO_UDK_PLAYING_TIME]];
	
	NSUInteger r = 0;
	switch ([ud integerForKey:VSO_UDK_PLAYING_FILL_PERCENTAGE]) {
		case 100: r = 0; break;
		case 90:  r = 1; break;
		case 75:  r = 2; break;
		case 60:  r = 3; break;
		case 50:  r = 4; break;
	}
	[pickerView selectRow:r inComponent:0 animated:NO];
	
	switch ([ud integerForKey:VSO_UDK_PLAYING_MODE]) {
		case VSOPlayingModeFillIn:    [pickerView setAlpha:1.]; [datePicker setAlpha:0.]; break;
		case VSOPlayingModeTimeLimit: [pickerView setAlpha:0.]; [datePicker setAlpha:1.]; break;
		default: [NSException raise:@"Unknown playing mode" format:@"The playing mode %d is not valid", r];
	}
}

- (IBAction)timeChanged:(id)sender
{
	if ([datePicker countDownDuration]<60) [datePicker setCountDownDuration:0];
	[[NSUserDefaults standardUserDefaults] setDouble:[datePicker countDownDuration] forKey:VSO_UDK_PLAYING_TIME];
}

- (NSUInteger)nPercentFromPickerRow:(NSUInteger)row
{
	switch (row) {
		case 0: return 100; break;
		case 1: return 90; break;
		case 2: return 75; break;
		case 3: return 60; break;
		case 4: return 50; break;
		default: [NSException raise:@"Unknown row in pickerView" format:@"The row %d is not valid for the percentage fill-in setting", row];
	}
	return 0;
}

/* TabelView dataSource and delegate */
#pragma mark Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"PlayingModeCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSUInteger r = [indexPath indexAtPosition:1];
	VSOPlayingMode m = [[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_PLAYING_MODE];
	if (m == r) cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else        cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = [VSOPlayingModeView playingModeStringFromInt:r];
	
	return cell;
}
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger r = [indexPath indexAtPosition:1];
	[[NSUserDefaults standardUserDefaults] setInteger:r forKey:VSO_UDK_PLAYING_MODE];
	[UIView beginAnimations:nil context:NULL];
	switch (r) {
		case 0: [pickerView setAlpha:1.]; [datePicker setAlpha:0.]; break;
		case 1: [pickerView setAlpha:0.]; [datePicker setAlpha:1.]; break;
		default: [NSException raise:@"Unknown indexPath in tableView" format:@"The indexPath %d is not valid for the playing mode setting (in tableView:didSelectRowAtIndexPath:)", r];
	}
	[UIView commitAnimations];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[tableView reloadData];
}


/* Datasource */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 5;
}

/* Delegate */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[[NSUserDefaults standardUserDefaults] setInteger:[self nPercentFromPickerRow:row] forKey:VSO_UDK_PLAYING_FILL_PERCENTAGE];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [NSString stringWithFormat:@"%d%%", [self nPercentFromPickerRow:row]];
}

@end


/********************************************************************************************************/
@implementation VSOSettingsViewController

@synthesize settings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) != nil) {
		UISettingsClasses = [[NSArray arrayWithObjects:[VSOLevelSizeView class], [VSOLevelDifficultyView class], [VSOChallengeShapeView class], [VSOPlayingModeView class], nil] retain];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
	
	controller.gameProgress = [[[VSOGameProgress alloc] initWithSettings:settings] autorelease];
	controller.delegate = self;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[tableViewForSettingList reloadData];
}

/* Settings table view dataSource */
#pragma mark Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"game settings", @"Label on top of the game settings");
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [UISettingsClasses count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	Class c = [UISettingsClasses objectAtIndex:[indexPath indexAtPosition:1]];
	cell.textLabel.text = [c settingName];
	cell.detailTextLabel.text = [c readableSettingValue];
	
	return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Class settingClass = [UISettingsClasses objectAtIndex:[indexPath indexAtPosition:1]];
	
	UIViewController *anotherViewController = [[settingClass alloc] initWithNibName:NSStringFromClass(settingClass) bundle:nil];
	anotherViewController.title = [settingClass settingName];
	[self.navigationController pushViewController:anotherViewController animated:YES];
	[anotherViewController release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
	[settings release];
	[UISettingsClasses release];
	
	[super dealloc];
}

@end

/*
 * VSOPlayingModeViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import "VSOPlayingModeViewController.h"

#import "Constants.h"



@implementation VSOPlayingModeViewController

+ (NSString *)localizedSettingValue
{
	return [self playingModeStringFromInt:[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_PLAYING_MODE]];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
	[self.datePicker setCountDownDuration:[ud doubleForKey:VSO_UDK_PLAYING_TIME]];
	
	NSUInteger r = 0;
	switch ([ud integerForKey:VSO_UDK_PLAYING_FILL_PERCENTAGE]) {
		case 100: r = 0; break;
		case 90:  r = 1; break;
		case 75:  r = 2; break;
		case 60:  r = 3; break;
		case 50:  r = 4; break;
	}
	[self.pickerView selectRow:r inComponent:0 animated:NO];
	
	switch ([ud integerForKey:VSO_UDK_PLAYING_MODE]) {
		case VSOPlayingModeFillIn:    [self.pickerView setAlpha:1.]; [self.datePicker setAlpha:0.]; break;
		case VSOPlayingModeTimeLimit: [self.pickerView setAlpha:0.]; [self.datePicker setAlpha:1.]; break;
		default: [NSException raise:@"Unknown playing mode" format:@"The playing mode %lu is not valid", (unsigned long)r];
	}
}

- (IBAction)timeChanged:(id)sender
{
	if ([self.datePicker countDownDuration]<60) [self.datePicker setCountDownDuration:0];
	[NSUserDefaults.standardUserDefaults setDouble:[self.datePicker countDownDuration] forKey:VSO_UDK_PLAYING_TIME];
}

/* ***** Table View Data Source & Delegate ***** */
#pragma mark - Table View Data Source & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"PlayingModeCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	NSUInteger r = [indexPath indexAtPosition:1];
	VSOPlayingMode m = [NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_PLAYING_MODE];
	if (m == r) cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else        cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = [self.class playingModeStringFromInt:r];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger r = [indexPath indexAtPosition:1];
	[NSUserDefaults.standardUserDefaults setInteger:r forKey:VSO_UDK_PLAYING_MODE];
	[UIView beginAnimations:nil context:NULL];
	switch (r) {
		case 0: [self.pickerView setAlpha:1.]; [self.datePicker setAlpha:0.]; break;
		case 1: [self.pickerView setAlpha:0.]; [self.datePicker setAlpha:1.]; break;
		default: [NSException raise:@"Unknown indexPath in tableView" format:@"The indexPath %lu is not valid for the playing mode setting (in tableView:didSelectRowAtIndexPath:)", (unsigned long)r];
	}
	[UIView commitAnimations];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[tableView reloadData];
}

/* ***** Picker View Data Source & Delegate ***** */
#pragma mark - Picker View Data Source & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 5;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[NSUserDefaults.standardUserDefaults setInteger:[self nPercentFromPickerRow:row] forKey:VSO_UDK_PLAYING_FILL_PERCENTAGE];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [NSString stringWithFormat:@"%lu%%", (unsigned long)[self nPercentFromPickerRow:row]];
}

/* ***** Private ***** */
#pragma mark - Private

+ (NSString *)playingModeStringFromInt:(NSUInteger)m
{
	switch (m) {
		case 0: return NSLocalizedString(@"fill in", @"Fill in play mode setting label"); break;
		case 1: return NSLocalizedString(@"time limit", @"Time limit play mode setting label"); break;
		default: [NSException raise:@"Unknown indexPath in tableView" format:@"The indexPath %lu is not valid for the playing mode setting", (unsigned long)m];
	}
	
	return @"";
}

- (NSUInteger)nPercentFromPickerRow:(NSUInteger)row
{
	switch (row) {
		case 0: return 100; break;
		case 1: return 90; break;
		case 2: return 75; break;
		case 3: return 60; break;
		case 4: return 50; break;
		default: [NSException raise:@"Unknown row in pickerView" format:@"The row %lu is not valid for the percentage fill-in setting", (unsigned long)row];
	}
	return 0;
}

@end

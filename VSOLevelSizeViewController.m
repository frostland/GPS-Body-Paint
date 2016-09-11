/*
 * VSOLevelSizeViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import "VSOLevelSizeViewController.h"

#import "Constants.h"



@implementation VSOLevelSizeViewController

+ (NSString *)localizedSettingValue
{
	return [self localizedStringFromNMeters:[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_SIZE]];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSUInteger s = [NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_SIZE];
	NSUInteger r = 0;
	switch (s) {
		case 25: r = 0; break;
		case 50: r = 1; break;
		case 75: r = 2; break;
	}
	
	[self.pickerView selectRow:r inComponent:0 animated:NO];
}

/* ***** Picker Data Source & Delegate ***** */
#pragma mark - Picker Data Source & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 3;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	[NSUserDefaults.standardUserDefaults setInteger:[self nMetersFromPickerRow:row] forKey:VSO_UDK_LEVEL_SIZE];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [self.class localizedStringFromNMeters:[self nMetersFromPickerRow:row]];
}

/* ***** Private ***** */
#pragma mark - Private

+ (NSString *)localizedStringFromNMeters:(NSUInteger)nMeters
{
	return [NSString stringWithFormat:NSLocalizedString(@"n meters format", nil), nMeters];
}

- (NSUInteger)nMetersFromPickerRow:(NSUInteger)row
{
	NSUInteger s = 0;
	switch (row) {
		case 0: s = 25; break;
		case 1: s = 50; break;
		case 2: s = 75; break;
		default: [NSException raise:@"Unknown row in pickerView" format:@"The row %lu is not valid for the level size setting", (unsigned long)row];
	}
	
	return s;
}

@end

/*
 * VSOPlayingModeViewController.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import <UIKit/UIKit.h>



@interface VSOPlayingModeViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource>

+ (NSString *)localizedSettingValue;

@property(nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property(nonatomic, retain) IBOutlet UIDatePicker *datePicker;

- (IBAction)timeChanged:(id)sender;

@end

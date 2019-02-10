/*
 * VSOLevelSizeViewController.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import <UIKit/UIKit.h>



@interface LevelSizeViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

+ (NSString *)localizedSettingValue;

@property(nonatomic, retain) IBOutlet UIPickerView *pickerView;

@end

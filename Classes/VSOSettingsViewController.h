//
//  FlipsideViewController.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/15/09.
//  Copyright VSO-Software 2009. All rights reserved.
//

#import "VSOPlayViewController.h"
#import "VSOSettings.h"

#import "VSOShapeView.h"

@interface VSOSettingsViewController : UIViewController <VSOPlayViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
	IBOutlet UITableView *tableViewForSettingList;
	
	VSOSettings *settings;
	
	NSArray *UISettingsClasses;
}
@property(nonatomic, retain) VSOSettings *settings;
- (IBAction)play:(id)sender;

@end

/***/
@interface VSOSettingViewController : UIViewController {
}
+ (NSString *)settingName;
+ (NSString *)readableSettingValue;

@end

/***/
@interface VSOChallengeShapeView : VSOSettingViewController {
	IBOutlet UISegmentedControl *segmentedControlChosenShape;
	IBOutlet VSOShapeView *shapeView;
	
	VSOGameShape *shape;
}
- (IBAction)shapeChanged:(id)sender;

@end

/***/
@interface VSOLevelDifficultyView : VSOSettingViewController {
/*	IBOutlet UISegmentedControl *segmentedControlChosenGridSize;*/
	IBOutlet UISegmentedControl *segmentedControlChosenPaintingSize;
}
/*- (IBAction)gridSizeChanged:(id)sender;*/
- (IBAction)levelPaintingSizeChanged:(id)sender;

@end

/***/
@interface VSOLevelSizeView : VSOSettingViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	IBOutlet UIPickerView *pickerView;
}

@end

/***/
@interface VSOPlayingModeView : VSOSettingViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIPickerView *pickerView;
	IBOutlet UIDatePicker *datePicker;
}
- (IBAction)timeChanged:(id)sender;

@end

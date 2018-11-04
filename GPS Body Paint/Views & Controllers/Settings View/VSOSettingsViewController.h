/*
 * VSOSettingsViewController
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright VSO-Software 2009. All rights reserved.
 */

#import "VSOPlayViewController.h"
#import "VSOSettings.h"



@interface VSOSettingsViewController : UITableViewController <VSOPlayViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>

@property(nonatomic, retain) VSOSettings *settings;

@property(nonatomic, retain) IBOutlet UILabel *labelLevelSize;
@property(nonatomic, retain) IBOutlet UILabel *labelLevelDifficulty;
@property(nonatomic, retain) IBOutlet UILabel *labelChallengeShape;
@property(nonatomic, retain) IBOutlet UILabel *labelPlayingMode;

@end

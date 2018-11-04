/*
 * VSOChallengeShapeViewController.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/11/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class GameShape, ShapeView;



@interface VSOChallengeShapeViewController : UIViewController {
	GameShape *shape;
}

+ (NSString *)localizedSettingValue;

@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentedControlChosenShape;
@property(nonatomic, retain) IBOutlet ShapeView *shapeView;

- (IBAction)shapeChanged:(id)sender;

@end

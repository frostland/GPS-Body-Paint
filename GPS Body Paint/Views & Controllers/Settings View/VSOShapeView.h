/*
 * VSOShapeView.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/23/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class GameShape;



@interface VSOShapeView : UIView

@property(nonatomic, retain) GameShape *gameShape;

@end

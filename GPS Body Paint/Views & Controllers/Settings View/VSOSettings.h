/*
 * VSOSettings.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/16/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Constants.h"
#import "VSOGameShape.h"



@interface VSOSettings : NSObject

@property(nonatomic) CLLocationDistance playgroundSize; /* Meters: Max size of the sides of the region of the map */
@property(nonatomic) CGFloat gridSize;
@property(nonatomic) CGFloat userLocationDiameter;

@property(nonatomic, retain) VSOGameShape *gameShape;
@property(nonatomic) VSOPlayingMode playingMode;
@property(nonatomic) NSTimeInterval playingTime;
@property(nonatomic) NSUInteger playingFillPercentToDo;

@end

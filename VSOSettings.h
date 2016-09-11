//
//  VSOSettings.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/16/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSOGameShape.h"
#import "Constants.h"

@interface VSOSettings : NSObject {
	CGFloat playgroundSize; /* Meters: max size of the sides of the region of the map */
	CGFloat gridSize;
	CGFloat userLocationDiameter;
	
	VSOGameShape *gameShape;
	VSOPlayingMode playingMode;
	NSTimeInterval playingTime;
	NSUInteger playingFillPercentToDo;
}
@property() CGFloat playgroundSize;
@property() CGFloat gridSize;
@property() CGFloat userLocationDiameter;

@property(nonatomic, retain) VSOGameShape *gameShape;
@property() VSOPlayingMode playingMode;
@property() NSTimeInterval playingTime;
@property() NSUInteger playingFillPercentToDo;

@end

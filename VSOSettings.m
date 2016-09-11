//
//  VSOSettings.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/16/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import "VSOSettings.h"

@implementation VSOSettings

@synthesize gameShape;
@synthesize playgroundSize;
@synthesize gridSize;
@synthesize userLocationDiameter;
@synthesize playingMode;
@synthesize playingTime;
@synthesize playingFillPercentToDo;

- (id)init
{
	if ((self = [super init]) != nil) {
		playgroundSize = 100;
		gridSize = 3;
		playgroundSize = 25;
		gridSize = 5;
	}
	
	return self;
}

@end

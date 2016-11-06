/*
 * VSOSettings.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/16/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import "VSOSettings.h"



@implementation VSOSettings

- (id)init
{
	if ((self = [super init]) != nil) {
		/* Defaults */
		self.playgroundSize = 100;
		self.gridSize = 3;
		self.playgroundSize = 25;
		self.gridSize = 5;
	}
	
	return self;
}

@end

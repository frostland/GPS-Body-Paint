/*
 * VSOShapeView.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/23/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import "VSOShapeView.h"



@implementation VSOShapeView

- (void)drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	[self.gameShape drawInRect:self.bounds withContext:c];
}

- (void)setGameShape:(VSOGameShape *)gs
{
	if (gs == self.gameShape) return;
	_gameShape = gs;
	
	[self setNeedsDisplay];
}

@end

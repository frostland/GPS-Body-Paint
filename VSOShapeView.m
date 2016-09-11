//
//  VSOShapeView.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/23/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import "VSOShapeView.h"

@implementation VSOShapeView

@synthesize gameShape;

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	[gameShape drawInRect:self.bounds withContext:c];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesCancelled:touches withEvent:event];
}

- (void)setGameShape:(VSOGameShape *)gs
{
	if (gs == gameShape) return;
	[gameShape release];
	gameShape = [gs retain];
	
	[self setNeedsDisplay];
}

- (void)dealloc
{
	[super dealloc];
}

@end

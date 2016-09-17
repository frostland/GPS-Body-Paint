/*
 * VSOCurLocationView.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 9/17/16.
 * Copyright © 2016 Frost Land. All rights reserved.
 */

#import "VSOCurLocationView.h"

#import "VSOUtils.h"
#import "Constants.h"

#define USER_LOCATION_VIEW_CENTER_DOT_SIZE 5.



@implementation VSOCurLocationView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		self.backgroundColor = UIColor.clearColor;
		self.contentMode = UIViewContentModeRedraw;
		
		self.heading = -1.;
		self.precision = 0.;
	}
	
	return self;
}

- (void)setFrame:(CGRect)f
{
	CGFloat s = MAX(USER_LOCATION_VIEW_CENTER_DOT_SIZE, self.precision + 3.);
	
	f.origin.x += (f.size.width -s)/2.;
	f.origin.y += (f.size.height-s)/2.;
	f.size.width = f.size.height = s;
	
	[super setFrame:f];
}

- (void)setPrecision:(CGFloat)p
{
	_precision = p;
	[self setFrame:self.frame];
}

- (void)setHeading:(CGFloat)h
{
	_heading = h;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	NSDLog(@"Drawing a VSOCurLocationView with rect: %@", NSStringFromCGRect(rect));
	
	CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2., rect.origin.y + rect.size.height/2.);
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	if (self.heading >= 0.) {
		CGContextConcatCTM(c, CGAffineTransformMakeTranslation(center.x, center.y));
		CGContextConcatCTM(c, CGAffineTransformMakeRotation(-2.*M_PI*(self.heading/360)));
		CGContextConcatCTM(c, CGAffineTransformMakeTranslation(-center.x, -center.y));
	}
	
	CGRect precisionRect = CGRectMake(center.x-self.precision/2., center.y-self.precision/2., self.precision, self.precision);
	UIColor *color = [UIColor colorWithRed:0.34901961 green:0.20392157 blue:0.08627451 alpha:1.];
	CGContextSetFillColorWithColor(c, [[color colorWithAlphaComponent:0.3] CGColor]);
	CGContextSetStrokeColorWithColor(c, [color CGColor]);
	CGContextSetLineWidth(c, 1.);
	
	CGContextFillEllipseInRect(c, precisionRect);
	CGContextStrokeEllipseInRect(c, precisionRect);
	
	if (self.heading >= 0.) {
		/* Heading is defined. Drawing the arrow. */
		CGFloat r = self.precision/2.;
		CGContextMoveToPoint(c, center.x, center.y-r);
		CGContextAddLineToPoint(c, center.x + cos(   M_PI/3.)*r, center.y + sin(   M_PI/3.)*r);
		CGContextAddLineToPoint(c, center.x + cos(2.*M_PI/3.)*r, center.y + sin(2.*M_PI/3.)*r);
		CGContextAddLineToPoint(c, center.x, center.y - r);
		
		CGContextSetFillColorWithColor(c, [[UIColor colorWithWhite:0.7 alpha:0.8] CGColor]);
		CGContextDrawPath(c, kCGPathFillStroke);
	} else {
		CGContextSetFillColorWithColor(c, [color CGColor]);
		CGContextFillEllipseInRect(c, CGRectMake(center.x-USER_LOCATION_VIEW_CENTER_DOT_SIZE/2., center.y-USER_LOCATION_VIEW_CENTER_DOT_SIZE/2., USER_LOCATION_VIEW_CENTER_DOT_SIZE, USER_LOCATION_VIEW_CENTER_DOT_SIZE));
	}
}

@end

//
//  VSOMapView.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/28/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import "VSOMapView.h"

#import "VSOUtils.h"

@implementation VSOMapView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	[(id <VSOMapViewDelegate>)self.delegate mapViewDidReceiveTouch:self];
	
	return [super hitTest:point withEvent:event];
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOMapView");
	
	[super dealloc];
}

@end

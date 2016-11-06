/*
 * VSOGridAnnotationView.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

#import "VSOGameProgress.h"
#import "VSOCurLocationView.h"



@interface VSOGridAnnotationView : MKAnnotationView <VSOGridPlayGame> {
	VSOCurLocationView *curUserLocationView;
	
	BOOL metedataComputed;
	CGRect gameRect, baseRect;
	NSUInteger xSize, ySize;
	CGPoint ***gridDescription;
	NSUInteger xStart, yStart;
}

@property(nonatomic, readonly) CGFloat totalArea;
@property(nonatomic, weak) MKMapView *map;
@property(nonatomic, weak) VSOGameProgress *gameProgress;

- (CGRect)rectFromGridPixelAtX:(NSUInteger)x andY:(NSUInteger)y;

@end

//
//  VSOGridAnnotationView.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/15/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

#import "VSOGameProgress.h"

@interface VSOCurLocationView : UIView {
	CGFloat heading;
	CGFloat precision;
}
@property() CGFloat heading;
@property() CGFloat precision;

@end

@interface VSOGridAnnotationView : MKAnnotationView <VSOGridPlayGame> {
	__weak MKMapView *map;
	__weak VSOGameProgress *gameProgress;
	
	VSOCurLocationView *curUserLocationView;
	
	BOOL metedataComputed;
	CGFloat totalArea;
	CGRect gameRect, baseRect;
	NSUInteger xSize, ySize;
	CGPoint ***gridDescription;
	NSUInteger xStart, yStart;
}
@property(readonly) CGFloat totalArea;
@property(nonatomic, weak) MKMapView *map;
@property(nonatomic, weak) VSOGameProgress *gameProgress;
- (CGRect)rectFromGridPixelAtX:(NSUInteger)x andY:(NSUInteger)y;

@end

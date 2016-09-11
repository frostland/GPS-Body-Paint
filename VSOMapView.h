//
//  VSOMapView.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/28/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>

/* Adding a delegate methode to the default MKMapView:
 *		- (void)mapViewDidReceiveTouch:(VSOMapView *)mpV;
 */

@protocol VSOMapViewDelegate <MKMapViewDelegate>

- (void)mapViewDidReceiveTouch:(MKMapView *)mpV;

@end


@interface VSOMapView : MKMapView {
}

@end

/*
 * MapView.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import MapKit



/**
Custom MapViewDelegate

Adds a delegate methode to the default MKMapView:

    func mapView(didReceiveTouch mapView: MKMapView) */
@objc
protocol VSOMapViewDelegate : MKMapViewDelegate {
	
	@objc optional func mapView(didReceiveTouch mapView: MKMapView)
	
}

class VSOMapView : MKMapView {
	
//	deinit {
//		NSLog("Deallocing a VSOMapView")
//	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		(delegate as? VSOMapViewDelegate)?.mapView?(didReceiveTouch: self)
		
		return super.hitTest(point, with: event)
	}
	
}

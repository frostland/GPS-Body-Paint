/*
 * MapUtils.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/20.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation
import MapKit



extension MKCoordinateRegion {
	
	/** It is assumed the region is valid (the span does not extend outside a
	valid location */
	var latitudeSpanInMeters: CLLocationDistance {
		let l1 = CLLocation(latitude: center.latitude - span.latitudeDelta/2, longitude: center.longitude)
		let l2 = CLLocation(latitude: center.latitude + span.latitudeDelta/2, longitude: center.longitude)
		return l1.distance(from: l2)
	}
	
	/** It is assumed the region is valid (the span does not extend outside a
	valid location */
	var longitudeSpanInMeters: CLLocationDistance {
		let l1 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta/2)
		let l2 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta/2)
		return l1.distance(from: l2)
	}
	
	/* Actual unit is CLLocationDistance^2 */
	var area: CLLocationDistance {
		return latitudeSpanInMeters * longitudeSpanInMeters
	}
	
}

/*
 * Constants.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 11/25/18.
 * Copyright 2018 Frost Land. All rights reserved.
 */

import CoreGraphics
import CoreLocation
import Foundation



class Constants {
	
	let timeBeforeShowingGettingLocMsg = TimeInterval(5)
	
	/** The max size of the sides of the region of the map. */
	let gridSize = CLLocationDistance(3)
	let maxMapSpanForPlayground = CLLocationDistance(500)
	
	let animTimeShowViewLoadingMap = TimeInterval(0.3)
	let animTimeShowArrows         = TimeInterval(0.5)
	let animTimeHideGettingLocMsg  = TimeInterval(0.65) /* More or less (more less than more) the animation time of the map animation */
	let animTimeShowGameOver       = TimeInterval(0.75)
	
}

/*
 * Settings.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreLocation
import CoreGraphics
import Foundation



class Settings : NSObject {
	
	/** The Max size of the sides of the region of the map. */
	@objc var playgroundSize = CLLocationDistance(25)
	@objc var gridSize = CLLocationDistance(5)
	@objc var userLocationDiameter = CLLocationDistance(8.1)
	
	@objc var gameShape = GameShape(type: .square)
	@objc var playingMode = VSOPlayingMode.fillIn
	@objc var playingTime = TimeInterval(5*60)
	@objc var playingFillPercentToDo = 75
	
}

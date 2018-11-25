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
	var playgroundSize = CLLocationDistance(25)
	var gridSize = CLLocationDistance(5)
	var userLocationDiameter = CLLocationDistance(8.1)
	
	var gameShape = GameShape(type: .square)
	var playingMode = PlayingMode.fillIn
	var playingTime = TimeInterval(5*60)
	var playingFillPercentToDo = 75
	
}

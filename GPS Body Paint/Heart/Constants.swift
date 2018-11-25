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



enum GameShapeType : Int {
	case square = 0
	case hexagon = 1
	case triangle = 2
}


enum PlayingMode : Int {
	case fillIn = 0
	case timeLimit = 1
}


struct Constants {
	
	struct UserDefault {
		
		static let firstLaunch = "First Launch"
		static let gameShape = "VSO Saved Game Shape"
		static let paintingSize = "VSO Level Painting Size"
		static let levelSize = "VSO Level Size"
		static let playingMode = "VSO Playing Mode"
		static let playingFillPercentage = "VSO Playing Mode Fill In - Chosen Percentage"
		static let playingTime = "VSO Playing Mode Time Limit - Time Chosen"
		static let warnOnMapLoadingFailure = "VSO Warn On Map Loading Failure"
		
		private init() {}
		
	}
	
	struct AnimTimes {
		
		static let showViewLoadingMap = TimeInterval(0.3)
		static let showArrows         = TimeInterval(0.5)
		static let hideGettingLocMsg  = TimeInterval(0.65) /* More or less (more less than more) the animation time of the map animation */
		static let showGameOver       = TimeInterval(0.75)
		
		private init() {}
		
	}
	
	static let timeBeforeShowingGettingLocMsg = TimeInterval(5)
	static let maxMapSpanForPlayground = CLLocationDistance(500)
	
	private init() {}
	
}

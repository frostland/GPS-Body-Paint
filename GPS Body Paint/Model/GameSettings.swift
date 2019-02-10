/*
 * GameSettings.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/2/10.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation



struct GameSettings {
	
	init(from appSettings: AppSettings) {
		playgroundSize = appSettings.levelSize
		gridSize = 3
		userLocationDiameter = 10 - CLLocationDistance(appSettings.paintingSize.rawValue)*1.9
		
		gameShape = appSettings.gameShape
		playingMode = appSettings.playingMode
	}
	
	/** The Max size of the sides of the region of the map. */
	var playgroundSize: CLLocationDistance
	var gridSize: CLLocationDistance
	var userLocationDiameter: CLLocationDistance
	
	var gameShape: GameShape
	var playingMode: PlayingMode
	
}

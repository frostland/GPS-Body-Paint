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
		paintingDiameter = 10 - CLLocationDistance(appSettings.paintingSize.rawValue)*1.9
		
		gameShape = appSettings.gameShape
		playingMode = appSettings.playingMode
	}
	
	/** The minimum distance in meters on the x or y axis of the visible portion
	of the map. Because phones are vertical, this distance will always be the
	visible distance in meters on the x axis of the map (latitude). */
	var playgroundSize: CLLocationDistance
	/** The size in meters of a cell of the playing grid. */
	var gridSize: CLLocationDistance
	/** The diameter of the user location brush in meters. */
	var paintingDiameter: CLLocationDistance
	
	var gameShape: GameShape
	var playingMode: PlayingMode
	
}

/*
 * GameProgress.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/18.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation



struct GameProgress {
	
	/** The center of the game */
	let center: CLLocationCoordinate2D
	
	/** The full area possible to fill. */
	let fullArea: CLLocationDistance /* Actual unit is a CLLocationDistance^2 */
	
	var grid: Grid
	
}

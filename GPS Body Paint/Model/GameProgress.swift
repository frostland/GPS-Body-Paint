/*
 * GameProgress.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/18.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation
import MapKit /* Needed for some pixel to area conversions */
import UIKit /* Needed for some pixel to area conversions */



class GameProgress {
	
	/** The center of the game */
	let center: CLLocationCoordinate2D
	
	/** The full area possible to fill. */
	let fullArea: CLLocationDistance /* Actual unit is a CLLocationDistance^2 */
	private(set) var filledArea = CLLocationDistance(0) /* Actual unit is a CLLocationDistance^2 */
	
	let grid: Grid
	private(set) var filledCoordinates = Set<Grid.Coordinate>()
	
	init(center c: CLLocationCoordinate2D, gameShape: GameShape, gridSizeInMeters: CLLocationDistance, gridView: UIView, mapView: MKMapView) {
		center = c
		
		let bounds = gridView.bounds
		let region = mapView.convert(bounds, toRegionFrom: gridView)
		let gridSizePixels = mapView.convert(MKCoordinateRegion(center: region.center, latitudinalMeters: gridSizeInMeters, longitudinalMeters: gridSizeInMeters), toRectTo: gridView).width
		
		grid = Grid(shape: gameShape, in: bounds, gridSize: gridSizePixels)
		
		let gridViewMapArea = region.area
		let gridViewPixelArea = gridView.bounds.width * gridView.bounds.height
		fullArea = CLLocationDistance(grid.area / gridViewPixelArea) * gridViewMapArea
	}
	
	/** Returns true if the fill actually did something. Crashes for out of
	bounds coordinates (when assertions are active). */
	func fillCoordinate(_ c: Grid.Coordinate) -> Bool {
		assert(c.row >= 0 && c.row < grid.nRows)
		assert(c.col >= 0 && c.col < grid.nCols)
		if filledCoordinates.insert(c).inserted {
			if let newPixelArea = grid[c]?.area() {
				filledArea += CLLocationDistance(newPixelArea/grid.area) * fullArea
			}
			return true
		}
		return false
	}
	
}

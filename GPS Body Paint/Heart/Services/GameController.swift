/*
 * GameController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/2/16.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreGraphics
import CoreLocation
import Foundation
import MapKit


/* All methods are called on the main thread. */
protocol GameControllerDelegate : class {
	
	func gameController(_ gameController: GameController, didChangeStatus newStatus: GameController.Status)
	
	func gameController(_ gameController: GameController, failedToRetrieveLocation error: Error)
	func gameController(_ gameController: GameController, didGetNewLocation newLocation: CLLocation?)
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?)
	
	func gameController(_ gameController: GameController, didVisitCoordinate coordinate: Grid.Coordinate, newProgress: GameProgress)
	
}


class GameController : NSObject, CLLocationManagerDelegate {
	
	/** If precision is not better than 25 meters, we cannot start playing */
	static let minHorizontalPrecisionToStartPlaying = CLLocationAccuracy(25)
	
	/** The status can only go “up.” Once you’ve reached gameOver, there’s no
	turning back. */
	enum Status {
		
		case idle
		case trackingUserPosition
		case playing(gameProgress: GameProgress, shapeView: UIView, mapView: MKMapView)
		case gameOver(gameProgress: GameProgress)
		
		var isIdle: Bool {
			switch self {
			case .idle: return true
			default:    return false
			}
		}
		
		var isTrackingUserPosition: Bool {
			switch self {
			case .trackingUserPosition, .playing: return true
			case .idle, .gameOver:                return false
			}
		}
		
		var gameProgress: GameProgress? {
			switch self {
			case .playing(gameProgress: let gp, shapeView: _, mapView: _), .gameOver(gameProgress: let gp):
				return gp
				
			case .idle, .trackingUserPosition:
				return nil
			}
		}
		
		var gameInfo: (gameProgress: GameProgress, shapeView: UIView, mapView: MKMapView)? {
			switch self {
			case .playing(let gi):                        return gi
			case .idle, .trackingUserPosition, .gameOver: return nil
			}
		}
		
	}
	
	let gameSettings: GameSettings
	weak var delegate: GameControllerDelegate?
	
	var status = Status.idle {
		didSet {
			delegate?.gameController(self, didChangeStatus: status)
		}
	}
	
	var gameProgress: GameProgress? {
		return status.gameInfo?.gameProgress
	}
	
	var isPlaying: Bool {
		return gameProgress != nil
	}
	
	var canStartPlaying: Bool {
		guard let loc = currentLocation else {return false}
		return !isPlaying && loc.horizontalAccuracy < GameController.minHorizontalPrecisionToStartPlaying
	}
	
	private(set) var currentLocation: CLLocation? {
		didSet {
			assert(Thread.isMainThread)
			delegate?.gameController(self, didGetNewLocation: currentLocation)
			
			if let (gameProgress, shapeView, mapView) = status.gameInfo, let newLocation = currentLocation {
				/* Let’s compute the quadrilaterals to add in the grid. */
				let oldLocation = oldValue ?? newLocation
				let newPixelLocation = mapView.convert(newLocation.coordinate, toPointTo: shapeView)
				let oldPixelLocation = mapView.convert(oldLocation.coordinate, toPointTo: shapeView)
				
				/* We consider the paint brush size in pixel is the same for the old
				 * and the new location, and on the x and y axis. Technically it is
				 * usually not true, but the difference should never be significant.*/
				let brushRadius = mapView.convert(MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: gameSettings.paintingDiameter/2, longitudinalMeters: gameSettings.paintingDiameter/2), toRectTo: shapeView).width
				
				let coordinatesToFill = gameProgress.grid.coordinatesIntersectingSurfaceBetweenCircles(
					Circle(center: newPixelLocation, radius: brushRadius),
					Circle(center: oldPixelLocation, radius: brushRadius),
					blacklisted: gameProgress.filledCoordinates
				)
				
				for c in coordinatesToFill {
					/* The test below should always be true */
					if gameProgress.fillCoordinate(c) {
						delegate?.gameController(self, didVisitCoordinate: c, newProgress: gameProgress)
					}
				}
				
				switch gameSettings.playingMode {
				case .timeLimit: (/*nop*/)
				case .fillIn(percentGoal: let goal):
					if gameProgress.filledPercent >= goal {
						status = .gameOver(gameProgress: gameProgress)
					}
				}
			}
		}
	}
	private(set) var currentHeading: CLHeading? {
		didSet {
			assert(Thread.isMainThread)
			delegate?.gameController(self, didGetNewHeading: currentHeading)
		}
	}
	
	init(settings: GameSettings) {
		gameSettings = settings
		
		locationManager = CLLocationManager()
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.pausesLocationUpdatesAutomatically = false
		
		super.init()
		
		locationManager.delegate = self
	}
	
	deinit {
		locationManager.stopUpdatingHeading()
		locationManager.stopUpdatingLocation()
	}
	
	@discardableResult
	func startTrackingPhonePosition() -> Bool {
		guard status.isIdle else {return false}
		status = .trackingUserPosition
		
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		locationManager.startUpdatingHeading()
		return true
	}
	
	@discardableResult
	func startPlaying(in shapeView: UIView, with mapView: MKMapView) -> Bool {
		guard canStartPlaying, let loc = currentLocation else {return false}
		
		status = .playing(
			gameProgress: GameProgress(
				center: loc.coordinate,
				gameShape: gameSettings.gameShape,
				gridSizeInMeters: gameSettings.gridSize,
				gridView: shapeView,
				mapView: mapView
			),
			shapeView: shapeView,
			mapView: mapView
		)
		
		/* Add visited quadrilaterals for current location */
		currentLocation = loc
		
		return true
	}
	
	@discardableResult
	func stopPlaying() -> Bool {
		switch status {
		case .playing(gameProgress: let gp, shapeView: _, mapView: _):
			status = .gameOver(gameProgress: gp)
			return true
			
		default:
			return false
		}
	}
	
	/* *********************************
	   MARK: - Location Manager Delegate
	   ********************************* */
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		assert(Thread.isMainThread)
		delegate?.gameController(self, failedToRetrieveLocation: error)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else {return}
		
		if location.horizontalAccuracy.sign == .plus {currentLocation = location}
		else                                         {currentLocation = nil}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		assert(Thread.isMainThread)
		if newHeading.headingAccuracy.sign == .plus {currentHeading = newHeading}
		else                                        {currentHeading = nil}
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	/* Dependencies */
	private let locationManager: CLLocationManager
	
}

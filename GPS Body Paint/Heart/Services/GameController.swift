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


/* All methods are called on the main thread. */
protocol GameControllerDelegate : class {
	
	func gameController(_ gameController: GameController, didChangeStatus newStatus: GameController.Status)
	
	func gameController(_ gameController: GameController, failedToRetrieveLocation error: Error)
	func gameController(_ gameController: GameController, didGetNewLocation newLocation: CLLocation?)
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?)
	
	func gameController(_ gameController: GameController, didChangeProgress progress: GameProgress)
	
}


class GameController : NSObject, CLLocationManagerDelegate {
	
	/** If precision is not better than 25 meters, we cannot start playing */
	static let minHorizontalPrecisionToStartPlaying = CLLocationAccuracy(25)
	
	enum Status {
		
		case idle
		case trackingUserPosition
		case playing(gameProgress: GameProgress)
		
		var gameProgress: GameProgress? {
			switch self {
			case .playing(gameProgress: let gp): return gp
			default:                             return nil
			}
		}
		
	}
	
	let gameSettings: GameSettings
	weak var delegate: GameControllerDelegate?
	
	var status = Status.idle
	
	var gameProgress: GameProgress? {
		return status.gameProgress
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
	
	func startTrackingPhonePosition() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		locationManager.startUpdatingHeading()
	}
	
	func startPlaying() {
		guard canStartPlaying else {return}
	}
	
	func stopPlaying() {
		guard isPlaying else {return}
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

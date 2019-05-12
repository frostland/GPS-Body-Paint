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
@objc /* To be compatible with NSHashTable */
protocol GameControllerDelegate {
	
	func gameController(_ gameController: GameController, failedToRetrieveLocation error: Error)
	func gameController(_ gameController: GameController, didGetNewLocation newLocation: CLLocation?)
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?)
	
}


class GameController : NSObject, CLLocationManagerDelegate {
	
	let gameSettings: GameSettings
	
	private(set) var grid: Grid?
	private(set) var filledArea: CGFloat = 0
	private(set) var timePlaying: TimeInterval?
	
	var isPlaying: Bool {
		return grid != nil
	}
	
	private(set) var currentLocation: CLLocation? {
		didSet {
			assert(Thread.isMainThread)
			for d in delegates.allObjects {
				d.gameController(self, didGetNewLocation: currentLocation)
			}
		}
	}
	private(set) var currentHeading: CLHeading? {
		didSet {
			assert(Thread.isMainThread)
			for d in delegates.allObjects {
				d.gameController(self, didGetNewHeading: currentHeading)
			}
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
	}
	
	/** Add a delegate to the delegates list. Must be called on the main thread. */
	func addDelegate(_ obj: GameControllerDelegate) {
		assert(Thread.isMainThread)
		delegates.add(obj)
	}
	
	/** Remove a delegate from the delegates list. Must be called on the main
	thread. */
	func removeDelegate(_ obj: GameControllerDelegate) {
		assert(Thread.isMainThread)
		delegates.remove(obj)
	}
	
	/* *********************************
      MARK: - Location Manager Delegate
	   ********************************* */
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		assert(Thread.isMainThread)
		for delegate in delegates.allObjects {
			delegate.gameController(self, failedToRetrieveLocation: error)
		}
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
	
	private var delegates = NSHashTable<GameControllerDelegate>.weakObjects()
	
}

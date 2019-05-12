/*
 * PlayViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import MapKit
import UIKit



protocol PlayViewControllerDelegate : class {
	
	func playViewControllerDidFinish(_ controller: PlayViewController)
	
}


class PlayViewController : UIViewController, GameControllerDelegate, VSOMapViewDelegate, MKOverlay {
	
	var gameController: GameController! {willSet {assert(gameController == nil)}}
	weak var delegate: PlayViewControllerDelegate?
	
	@IBOutlet var mapView: VSOMapView!
	@IBOutlet var viewShapePreview: ShapeView?
	
	@IBOutlet var labelPlayingTime: UILabel!
	@IBOutlet var labelPlayingTimeTitle: UILabel!
	@IBOutlet var labelPercentFilled: UILabel!
	@IBOutlet var labelGoal: UILabel!
	@IBOutlet var labelGoalPercentage: UILabel!
	
	@IBOutlet var labelGPSAccuracy: UILabel!
	
	@IBOutlet var viewGettingLocation: UIView!
	@IBOutlet var viewLoadingMap: UIView!
	@IBOutlet var viewGameOver: UIView!
	
	@IBOutlet var buttonLockMap: UIButton!
	@IBOutlet var buttonCenterMap: UIButton?
	@IBOutlet var imageArrowTop: UIImageView!
	@IBOutlet var imageArrowRight: UIImageView!
	@IBOutlet var imageArrowDown: UIImageView!
	@IBOutlet var imageArrowLeft: UIImageView!
	
	@IBOutlet var wonLabelPlayingTime: UILabel!
	@IBOutlet var wonLabelFilledPercent: UILabel!
	@IBOutlet var wonLabelFilledSquareMeters: UILabel!
	
	required init?(coder aDecoder: NSCoder) {
		coordinateForAnnotation = CLLocationCoordinate2D(latitude: 43.580212, longitude: 1.29724)
		coordinateForAnnotation = CLLocationCoordinate2D(latitude: 40.792651, longitude: -73.959167)
//		coordinateForAnnotation = CLLocationCoordinate2D(latitude: 43.580212 + CLLocationDegrees.random(in: 0...9), longitude: 1.29724 + CLLocationDegrees.random(in: 0...9))
		
		warnForMapLoadingErrors = s.warnOnMapLoadingFailure
		
		super.init(coder: aDecoder)
	}
	
	deinit {
//		NSLog("Deallocing a PlayViewController")
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* Let's disable the auto-lock of the phone */
		UIApplication.shared.isIdleTimerDisabled = true
		
		gameController.addDelegate(self)
		
		viewGameOver.alpha = 0
		
		imageArrowTop.alpha = 0
		imageArrowDown.alpha = 0
		imageArrowLeft.alpha = 0
		imageArrowRight.alpha = 0
		
		viewLoadingMap.alpha = 0
		labelPercentFilled.text = NSLocalizedString("NA", comment: "")
		labelPlayingTime.text = NSLocalizedString("NA", comment: "")
		labelGPSAccuracy.text = NSLocalizedString("NA", comment: "")
		
		let font: UIFont
		let playingOrRemainingTitle: String
		switch gameSettings.playingMode {
		case .fillIn(let goal):
			font = labelPlayingTimeTitle.font
			playingOrRemainingTitle = NSLocalizedString("playing time", comment: "Playing time label title in the game view")
			
			labelGoal.isHidden = false
			labelGoalPercentage.isHidden = false
			labelGoalPercentage.text = String(format: NSLocalizedString("percent complete format", comment: "Here, there is only a %d with the percent sign (%% for %) following"), goal)
			
		case .timeLimit:
			font = labelGoal.font
			playingOrRemainingTitle = NSLocalizedString("remaining time", comment: "Remaining time label title in the game view")
			
			labelGoal.isHidden = true
			labelGoalPercentage.isHidden = true
		}
		labelPlayingTime.font = font
		labelPlayingTimeTitle.font = font
		labelPlayingTimeTitle.text = playingOrRemainingTitle
		
		#if !SIMULATOR_CODE
			locationManager.requestWhenInUseAuthorization()
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
		#else
//			refreshFalseLocation(nil)
			t = Timer.scheduledTimer(timeInterval: 3.3, target: self, selector: #selector(PlayViewController.refreshFalseLocation(_:)), userInfo: nil, repeats: true)
		#endif
		
		mapView.delegate = self
		mapView.mapType = .satellite
		viewShapePreview?.gameShape = gameProgress.settings.gameShape
		
		refreshTimes(nil)
		timerRefreshTimes = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(PlayViewController.refreshTimes(_:)), userInfo: nil, repeats: true)
	}
	
	/* ***************
      MARK: - Actions
	   *************** */
	
	@IBAction func centerMapToCurrentUserLocation(_ sender: AnyObject) {
		let r = MKCoordinateRegion(center: coordinateForAnnotation, latitudinalMeters: gameProgress.settings.playgroundSize, longitudinalMeters: gameProgress.settings.playgroundSize)
		mapView.setRegion(r, animated: true)
	}
	
	@IBAction func lockMapStopPlayingButtonAction(_ sender: AnyObject) {
		if !mapLocked {lockMap(sender as? UIButton)}
		else          {stopPlaying(sender)}
	}
	
	@IBAction func stopPlaying(_ sender: AnyObject) {
		finishGame()
		
		mapView.delegate = nil
		mapView.removeAnnotation(self)
		delegate?.playViewControllerDidFinish(self)
	}
	
	/* *********************************
      MARK: - Location Manager Delegate
	   ********************************* */
	
	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		guard newHeading.headingAccuracy.sign == .plus else {return}
		gameProgress.setCurrentHeading(newHeading.trueHeading)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let newLocation = locations.last else {return}
		let lastCoordinate = newLocation.coordinate
//		NSLog("did get location: %g, %g. Horizontal accuracy: %g", lastCoordinate.latitude, lastCoordinate.longitude, newLocation.horizontalAccuracy)
		
		/* Negative accuracy means no location found */
		guard newLocation.horizontalAccuracy.sign == .plus else {return}
//		guard newLocation.horizontalAccuracy <= gameProgress.settings.levelSize else {return}
		
		lastGPSRefresh = Date()
		labelGPSAccuracy.text = String(format: NSLocalizedString("n m format", comment: "Format for \"10 m\""), Int(newLocation.horizontalAccuracy.rounded()))
		
		if s.firstLaunch {
			s.firstLaunch = false
			
			let alertController = UIAlertController(
				title: NSLocalizedString("play info", comment: "Pop-up title when playing for the first time"),
				message: NSLocalizedString("lock map when ready msg", comment: "Pop-up title when playing for the first time"),
				preferredStyle: .alert
			)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
			present(alertController, animated: true, completion: nil)
		}
		
		if !mapLocked {
			coordinateForAnnotation = lastCoordinate;
			
			if !userMovedMap {centerMapToCurrentUserLocation(self)}
			
			mapFirstCenterDone = true
			removeGettingLocationMsgAnimated()
		} else {
			gameProgress.playerMoved(
				to: mapView.convert(lastCoordinate, toPointTo: mapView),
				diameter: mapView.convert(MKCoordinateRegion(center: lastCoordinate, latitudinalMeters: gameProgress.settings.userLocationDiameter, longitudinalMeters: gameProgress.settings.userLocationDiameter), toRectTo: mapView).width
			)
			let passtr = String(format: NSLocalizedString("percent complete format from float", comment: "Here, there is only a %.0f with the percent sign (%% for %) following"), gameProgress.percentDone)
			labelPercentFilled.text = passtr
			wonLabelFilledPercent.text = passtr
			
			/* Showing arrows if user outside of map */
			let r = mapView.region
			UIView.animate(withDuration: c.animTimeShowArrows, animations: {
				if lastCoordinate.latitude < r.center.latitude-r.span.latitudeDelta/2 {self.imageArrowDown.alpha = 1}
				else                                                                  {self.imageArrowDown.alpha = 0}
				if lastCoordinate.latitude > r.center.latitude+r.span.latitudeDelta/2 {self.imageArrowTop.alpha = 1}
				else                                                                  {self.imageArrowTop.alpha = 0}
				if lastCoordinate.longitude < r.center.longitude-r.span.longitudeDelta/2 {self.imageArrowLeft.alpha = 1}
				else                                                                     {self.imageArrowLeft.alpha = 0}
				if lastCoordinate.longitude > r.center.longitude+r.span.longitudeDelta/2 {self.imageArrowRight.alpha = 1}
				else                                                                     {self.imageArrowRight.alpha = 0}
			})
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let alertController = UIAlertController(
			title: NSLocalizedString("cannot get location", comment: "Title of the cannot get location popup"),
			message: NSLocalizedString("cannot get location. aborting play", comment: "Message of the cannot get location popup"),
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
			self.stopPlaying(self)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
	/* ********************
      MARK: - MKAnnotation
	   ******************** */
	
	var coordinate: CLLocationCoordinate2D {
		if mapLocked {return mapView.region.center}
		return coordinateForAnnotation
	}
	
	/* *************************
      MARK: - Map View Delegate
	   ************************* */
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation === self else {return nil}
		
		/* Try to dequeue an existing grid view first. */
		gridAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "GridAnnotation") as? GridAnnotationView
		
		if let annotationView = gridAnnotationView {annotationView.annotation = annotation}
		else                                       {gridAnnotationView = GridAnnotationView(annotation: annotation, reuseIdentifier: "GridAnnotation")}
		
		let delta = CGFloat(0)
		gridAnnotationView.frame = mapView.frame.insetBy(dx: -delta, dy: -delta)
		gameProgress.gridPlayGame = gridAnnotationView
		gridAnnotationView.gameProgress = gameProgress
		gridAnnotationView.map = mapView
		gameProgress.gameDidStart(
			location: mapView.convert(coordinateForAnnotation, toPointTo: mapView),
			diameter: mapView.convert(MKCoordinateRegion(center: coordinateForAnnotation, latitudinalMeters: gameProgress.settings.userLocationDiameter, longitudinalMeters: gameProgress.settings.userLocationDiameter), toRectTo: mapView).width
		)
		return gridAnnotationView
	}
	
	func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//		NSLog("mapViewWillStartLoadingMap(_:)")
		buttonLockMap.isEnabled = false
		
		if timerShowLoadingMap != nil {return}
		timerShowLoadingMap = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(PlayViewController.showViewLoadingMap(_:)), userInfo: nil, repeats: false)
	}
	
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//		NSLog("mapViewDidFinishLoadingMap(_:)")
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
		
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewLoadingMap.alpha = 0
		})
		
		buttonLockMap.isEnabled = true
	}
	
	func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
//		NSLog("mapViewDidFailLoadingMap(_:withError:)")
		guard !mapMoving && warnForMapLoadingErrors else {
			if !mapMoving {mapViewDidFinishLoadingMap(mapView)}
			return
		}
		
		warnForMapLoadingErrors = false
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
		
		let alertController = UIAlertController(
			title: NSLocalizedString("cannot get map", comment: "Title of the cannot load map popup"),
			message: NSLocalizedString("cannot get map, please check network", comment: "Message of the cannot load map popup"),
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("play anyway", comment: "Play anyway button on the cannot load map popup"), style: .default, handler: nil))
		alertController.addAction(UIAlertAction(title: NSLocalizedString("stop playing", comment: "Stop playing button on the cannot load map popup"), style: .cancel, handler: { _ in
			self.stopPlaying(self)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
	/* VSO Specific. NOT in original Map View Delegate... */
	func mapView(didReceiveTouch mapView: MKMapView) {
		userMovedMap = true
	}
	
	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//		NSLog("mapView(_:regionWillChangeAnimated:)")
		
		mapMoving = true
		buttonLockMap.isEnabled = false
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//		NSLog("mapView(_:regionDidChangeAnimated:)")
		mapMoving = false
		buttonLockMap.isEnabled = true
		
//		NSLog("Map width: %g meters", mapWidth)
/*		let w = Int(mapWidth.rounded())
		labelScale?.text = String(format: NSLocalizedString("n m format", comment: ""), w/4)
		if w > VSO_MAX_MAP_SPAN_FOR_PLAYGROUND {labelScale?.textColor = .red}
		else                                   {labelScale?.textColor = .white}*/
		if mapFirstCenterDone {viewShapePreview?.isHidden = false}
	}
	
	/* ******************************
      MARK: - Game Progress Delegate
	   ****************************** */
	
	/* Called by the game progress controller */
	func gameDidFinish(won: Bool) {
		finishGame()
		
		let k = 1/mapView.convert(MKCoordinateRegion(center: coordinateForAnnotation, latitudinalMeters: 1, longitudinalMeters: 1), toRectTo: mapView).width
		wonLabelFilledSquareMeters.text = String(format: NSLocalizedString("n square meters format", comment: "Format for \"10 square meters\""), Int((sqrt(gameProgress.doneArea)*k).rounded()))
		
		UIView.animate(withDuration: c.animTimeShowGameOver, animations: {
			self.viewGameOver.alpha = 1
		})
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	/* Dependencies */
	private let c = S.sp.constants
	private let s = S.sp.appSettings
	
	private var gridAnnotationView: GridAnnotationView! /* TODO: Check forced unwrap */
	private var timerShowLoadingMap: Timer?
	
	private var playingTime = TimeInterval(0)
	
	private var coordinateForAnnotation: CLLocationCoordinate2D
	private var lastGPSRefresh: Date?
	
	private var timerRefreshTimes: Timer?
	
	private var userMovedMap = false, mapFirstCenterDone = false
	private var mapLocked = false, mapMoving = false
	private var warnForMapLoadingErrors: Bool
	
#if SIMULATOR_CODE
	private var t: Timer?
	private var currentLocation: CLLocation?
#endif
	
	private var gameSettings: GameSettings {
		return gameController.gameSettings
	}
	
	private var mapWidth: CLLocationDistance {
		let r = mapView.region
		let l1 = CLLocation(latitude: r.center.latitude,                        longitude: r.center.longitude)
		let l2 = CLLocation(latitude: r.center.latitude + r.span.latitudeDelta, longitude: r.center.longitude)
		return l1.distance(from: l2)
	}
	
	private var score: Int {
		let k = 1/mapView.convert(MKCoordinateRegion(center: coordinateForAnnotation, latitudinalMeters: 1, longitudinalMeters: 1), toRectTo: mapView).width
		let area = Double(sqrt(gameProgress.doneArea)*k)
		let scoreMultiplier = 1 + Double(s.paintingSize.rawValue)/2
		
		return Int(((area / log10(playingTime+1.5)) * scoreMultiplier).rounded())
	}
	
	@objc
	private func showViewLoadingMap(_ timer: Timer) {
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
		
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewLoadingMap.alpha = 1
		})
	}
	
	private func showViewGettingLocation() {
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewGettingLocation.alpha = 1
		})
	}
	
	private func removeGettingLocationMsgAnimated() {
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewGettingLocation.alpha = 0
		})
	}
	
	private func lockMap(_ lockButton: UIButton?) {
		mapLocked = true
		/* If the current region of the map is too big, we decrease it */
		let max = c.maxMapSpanForPlayground
		if mapWidth > max {mapView.region = MKCoordinateRegion(center: mapView.region.center, latitudinalMeters: max, longitudinalMeters: max)}
		
		mapView.isZoomEnabled = false
		mapView.isScrollEnabled = false
		mapView.showsUserLocation = false
		mapView.addAnnotation(self)
		
		buttonCenterMap?.removeFromSuperview(); buttonCenterMap = nil
		viewShapePreview?.removeFromSuperview(); viewShapePreview = nil
/*		viewMapScale?.removeFromSuperview(); viewMapScale = nil; labelScale = nil
		viewPlayInfos.isHidden = false*/
		
		labelPercentFilled.text = String(format: NSLocalizedString("percent complete format", comment: ""), 0)
		wonLabelFilledPercent.text = String(format: NSLocalizedString("percent complete format", comment: ""), 0)
		lockButton?.setTitle(NSLocalizedString("stop playing", comment: "Stop playing button title"), for: .normal)
	}
	
	@objc
	private func refreshTimes(_ t: Timer?) {
		if mapLocked {
			playingTime = -gameProgress.startDate!.timeIntervalSinceNow /* TODO: Check forced unwrap */
			
			let i = Int(playingTime)
			let h = i/3600, m = (i - h*3600)/60, s = i - h*3600 - m*60
			let tasstr = String(format: "%02lu:%02lu:%02lu", h, m, s)
			wonLabelPlayingTime.text = tasstr
			
			let i2: Int
			switch gameProgress.settings.playingMode {
			case .fillIn:              i2 = i
			case .timeLimit(let time): i2 = Int(max(TimeInterval(0), time - playingTime))
			}
			let h2 = i2/3600, m2 = (i2 - h2*3600)/60, s2 = i2 - h2*3600 - m2*60
			let tasstr2 = String(format: "%02lu:%02lu:%02lu", h2, m2, s2)
			labelPlayingTime.text = tasstr2
		}
		
		if let lastGPSRefresh = lastGPSRefresh {
			let i = -lastGPSRefresh.timeIntervalSinceNow
			if mapLocked && i > c.timeBeforeShowingGettingLocMsg {showViewGettingLocation()}
		}
	}
	
	private func finishGame() {
		UIApplication.shared.isIdleTimerDisabled = false
		
		gameProgress.gameDidFinish()
		
#if SIMULATOR_CODE
		t?.invalidate()
		t = nil
#endif
		
		locationManager.stopUpdatingHeading()
		locationManager.stopUpdatingHeading()
		
		timerRefreshTimes?.invalidate()
		timerRefreshTimes = nil
		
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
	}
	
#if SIMULATOR_CODE
	/* Simulator code (location generation) */
	@objc
	private func refreshFalseLocation(_ t: Timer?) {
		let md = CGFloat(0.00003*4)
		coordinateForAnnotation.latitude  += CGFloat.random(in: -md...md)
		coordinateForAnnotation.longitude += CGFloat.random(in: -md...md)
		
		let newLoc = CLLocation(coordinate: coordinateForAnnotation, altitude: 0, horizontalAccuracy: CGFloat.random(in: 3...12), verticalAccuracy: -1, timestamp: Date())
		locationManager(locationManager, didUpdateLocations: [newLoc])
		
		currentLocation = newLoc
	}
#endif
	
}

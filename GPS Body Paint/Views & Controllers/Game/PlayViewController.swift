/*
 * PlayViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/12.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation
import MapKit
import UIKit



protocol PlayViewControllerDelegate : AnyObject {
	
	func playViewControllerDidFinish(_ controller: PlayViewController)
	
}

/* The play view controller is a relatively complex controller. It has a lot of
 * outlets and a few dynamic states.
 *    + Is the map loaded? If not, after a delay we show the “map is loading”
 *      view.
 *    + Is the user playing? If not, the play info will differ, and we won’t
 *      show the same overlays over the map.
 *    + Is the current GPS position precise enough? If not, we’ll show a getting
 *      position view above the play view.
 * We could probably split this controller in at least two, if not three parts.
 * But it is not done… */

class PlayViewController : UIViewController {
	
	weak var delegate: PlayViewControllerDelegate?
	var gameController: GameController! {
		willSet {
			/* We allow the game controller to be set once only */
			assert(gameController == nil)
			newValue?.delegate = self
		}
	}
	
	@IBOutlet var mapView: VSOMapView!
	@IBOutlet var viewMapOverlay: UIView!
	@IBOutlet var shapeView: ShapeView!
	@IBOutlet var gridView: GridView!
	@IBOutlet var locationBrushView: LocationBrushView!
	@IBOutlet var contraintShapeViewSize: NSLayoutConstraint!
	
	@IBOutlet var buttonStartStopPlay: UIButton!
	
	@IBOutlet var labelPlayingTime: UILabel!
	@IBOutlet var labelPlayingTimeTitle: UILabel!
	@IBOutlet var labelPercentFilled: UILabel!
	@IBOutlet var labelGoal: UILabel!
	@IBOutlet var labelGoalPercentage: UILabel!
	
	@IBOutlet var labelGPSAccuracy: UILabel!
	
	@IBOutlet var viewGettingLocation: UIView!
	@IBOutlet var viewLoadingMap: UIView!
	@IBOutlet var viewGameOver: UIView!
	
	@IBOutlet var imageArrowTop: UIImageView!
	@IBOutlet var imageArrowRight: UIImageView!
	@IBOutlet var imageArrowDown: UIImageView!
	@IBOutlet var imageArrowLeft: UIImageView!
	
	@IBOutlet var wonLabelPlayingTime: UILabel!
	@IBOutlet var wonLabelFilledPercent: UILabel!
	@IBOutlet var wonLabelFilledSquareMeters: UILabel!
	
	/* ****************************
	   MARK: - Controller Lifecycle
	   **************************** */
	
	deinit {
		timerUpdateTimeLabels?.invalidate()
		timerUpdateTimeLabels = nil
		
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/* I’d have prefered the map type to be satellite, but because of
		 * unforeseen limitations, this won’t be possible. The map has a maximum
		 * zoom level which is way lower when map type is satellite than standard.
		 * On an Xs, the map is so small the pixel grid size becomes 0 and the app
		 * crashes… */
		if #available(iOS 11.0, *) {
			mapView.mapType = .mutedStandard
		}
		centerMap(locationCoordinate: mapView.centerCoordinate)
		
		buttonStartStopPlay.isEnabled = false
		
		imageArrowTop.alpha = 0
		imageArrowDown.alpha = 0
		imageArrowLeft.alpha = 0
		imageArrowRight.alpha = 0
		
		let font: UIFont
		let playingOrRemainingTitle: String
		switch gameController.gameSettings.playingMode {
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
		
		updateTimeLabels(nil)
		
		viewLoadingMap.alpha = 0
		viewMapOverlay.isHidden = true
		locationBrushView.isHidden = true
		shapeView.gameShape = gameController.gameSettings.gameShape
		
		viewGettingLocation.alpha = 0
		viewGettingLocation.frame = view.bounds
		view.addSubview(viewGettingLocation)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		gameController.startTrackingPhonePosition()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		gameController.stopPlaying()
	}
	
	/* ***************************
	   MARK: - Controller Settings
	   *************************** */
	
//	override var prefersStatusBarHidden: Bool {
//		return true
//	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	/* ***************
	   MARK: - Actions
	   *************** */
	
	@IBAction func startOrStopPlaying(_ sender: UIButton) {
		if !gameController.isPlaying {
			gameController.startPlaying(in: shapeView, with: mapView)
		} else {
			gameController.stopPlaying()
		}
	}
	
	/* Note: This method is currently inaccessible through theh UI… */
	@IBAction func centerMapToCurrentUserLocation(_ sender: AnyObject) {
		guard let loc = gameController.currentLocation else {return}
		
		userHasMovedMap = false
		centerMap(locationCoordinate: loc.coordinate)
	}
	
	@IBAction func quitPlayView(_ sender: AnyObject) {
		gameController.stopPlaying()
		delegate?.playViewControllerDidFinish(self)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private let c = S.sp.constants
	private let s = S.sp.appSettings
	
	private var userHasMovedMap = false
	
	private var mapMoving = false
	private var timerShowLoadingMap: Timer?
	private var timerShowGettingLocation: Timer?
	
	private var timerUpdateTimeLabels: Timer?
	
	private func updateLocationBrushFrame() {
		guard let loc = gameController.currentLocation else {return}
		
		let locationBrushRegion = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: gameController.gameSettings.paintingDiameter, longitudinalMeters: gameController.gameSettings.paintingDiameter)
		locationBrushView.frame = mapView.convert(locationBrushRegion, toRectTo: locationBrushView.superview!)
	}
	
	private func centerMap(locationCoordinate coord: CLLocationCoordinate2D) {
		let mapToOverlayRatio: CGFloat
		if viewMapOverlay.frame.width > viewMapOverlay.frame.height {
			mapToOverlayRatio = mapView.frame.height / viewMapOverlay.frame.height
		} else {
			mapToOverlayRatio = mapView.frame.width / viewMapOverlay.frame.width
		}
	
		/* The overlay view is smaller than the map (by design) */
		let extendedPlaygroundSize = gameController.gameSettings.playgroundSize * CLLocationDistance(mapToOverlayRatio)
	
		let regionWeWant = MKCoordinateRegion(center: coord, latitudinalMeters: extendedPlaygroundSize, longitudinalMeters: extendedPlaygroundSize)
//		let regionWeGet = mapView.regionThatFits(regionWeWant)
		mapView.setRegion(regionWeWant, animated: false)
	
		/* The map view has a maximum zoom. It’s Whoozer all over again! (Well
		 * not exactly, but we do end up with a different region than what we
		 * asked…). Note: The region we get is (almost exactly, minus rounding
		 * errors) “mapView.regionThatFits(regionWeWant)”.
		 * To workaround this, we change the size of the shape view so the
		 * shape has the user’s defined span on the map. This is done in the
		 * mapView delegate method mapViewDidChangeVisibleRegion. Note we could
		 * whoozer’ize the map (apply an affine transform on the map to do the
		 * zoom ourselves), but 1/ the solution is complex to implement (too
		 * complex for this project anyway) and 2/ I’m not sure it is allowed
		 * per Apple’s guidelines. */
		
		/* Let’s show/hide the out of map arrows if needed */
		showOutOfMapArrows()
	}
	
	private func showOutOfMapArrows() {
		guard let coord = gameController.currentLocation?.coordinate else {return}
		
		/* Showing arrows if user outside of map */
		let r = mapView.region
		UIView.animate(withDuration: c.animTimeShowArrows, animations: {
			if coord.latitude < r.center.latitude-r.span.latitudeDelta/2 {self.imageArrowDown.alpha = 1}
			else                                                         {self.imageArrowDown.alpha = 0}
			if coord.latitude > r.center.latitude+r.span.latitudeDelta/2 {self.imageArrowTop.alpha = 1}
			else                                                         {self.imageArrowTop.alpha = 0}
			if coord.longitude < r.center.longitude-r.span.longitudeDelta/2 {self.imageArrowLeft.alpha = 1}
			else                                                            {self.imageArrowLeft.alpha = 0}
			if coord.longitude > r.center.longitude+r.span.longitudeDelta/2 {self.imageArrowRight.alpha = 1}
			else                                                            {self.imageArrowRight.alpha = 0}
		})
	}
	
	@objc
	private func updateTimeLabels(_ timer: Timer?) {
		guard let timePlaying = gameController.gameProgress?.timePlaying else {
			labelPercentFilled.text = NSLocalizedString("NA", comment: "")
			labelPlayingTime.text = NSLocalizedString("NA", comment: "")
			labelGPSAccuracy.text = NSLocalizedString("NA", comment: "")
			return
		}
		
		let dateFormatter = DateComponentsFormatter()
		dateFormatter.unitsStyle = .positional
		dateFormatter.allowedUnits = [.hour, .minute, .second]
		dateFormatter.zeroFormattingBehavior = DateComponentsFormatter.ZeroFormattingBehavior()
		
		wonLabelPlayingTime.text = dateFormatter.string(from: timePlaying)
		
		let time2: TimeInterval
		switch gameController.gameSettings.playingMode {
		case .fillIn:              time2 = timePlaying
		case .timeLimit(let time): time2 = max(TimeInterval(0), time - timePlaying)
		}
		labelPlayingTime.text = dateFormatter.string(from: time2)
	}
	
	private func refreshGettingLocationTimerAndView() {
		hideGettingLocationView()
		
		if gameController.isPlaying {
			timerShowGettingLocation?.invalidate()
			timerShowGettingLocation = Timer.scheduledTimer(timeInterval: c.timeBeforeShowingGettingLocMsg, target: self, selector: #selector(showGettingLocationView(_:)), userInfo: nil, repeats: false)
		} else {
			timerShowGettingLocation?.invalidate()
			timerShowGettingLocation = nil
		}
	}
	
	@objc
	private func showGettingLocationView(_ timer: Timer?) {
		timerShowGettingLocation?.invalidate()
		timerShowGettingLocation = nil
		
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewGettingLocation.alpha = 1
		})
	}
	
	private func hideGettingLocationView() {
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewGettingLocation.alpha = 0
		})
	}
	
}

/* *************************
   MARK: - Map View Delegate
   ************************* */

extension PlayViewController : VSOMapViewDelegate {
	
	/* VSO Map view delegate specific */
	func mapView(didReceiveTouch mapView: MKMapView) {
		userHasMovedMap = true
	}
	
	func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//		NSLog("mapViewWillStartLoadingMap")
		
		buttonStartStopPlay.isEnabled = false
		
		guard timerShowLoadingMap == nil else {return}
		timerShowLoadingMap = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(PlayViewController.showViewLoadingMap(_:)), userInfo: nil, repeats: false)
	}
	
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//		NSLog("mapViewDidFinishLoadingMap")
		
		buttonStartStopPlay.isEnabled = true
		
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
		
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewLoadingMap.alpha = 0
		})
	}
	
	@objc
	private func showViewLoadingMap(_ sender: Timer) {
		UIView.animate(withDuration: c.animTimeShowViewLoadingMap, animations: {
			self.viewLoadingMap.alpha = 1
		})
	}
	
	func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
		guard !mapMoving && s.warnOnMapLoadingFailure else {
			if !mapMoving {mapViewDidFinishLoadingMap(mapView)}
			return
		}
		
		s.warnOnMapLoadingFailure = false
		timerShowLoadingMap?.invalidate()
		timerShowLoadingMap = nil
		
		let alertController = UIAlertController(
			title: NSLocalizedString("cannot get map", comment: "Title of the cannot load map popup"),
			message: NSLocalizedString("cannot get map, please check network", comment: "Message of the cannot load map popup"),
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("play anyway", comment: "Play anyway button on the cannot load map popup"), style: .default, handler: nil))
		alertController.addAction(UIAlertAction(title: NSLocalizedString("stop playing", comment: "Stop playing button on the cannot load map popup"), style: .cancel, handler: { _ in
			self.quitPlayView(self)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		guard !gameController.isPlaying else {return}
		
		/* Let’s update the shape view size (see the didGetNewLocation method). */
		let regionWeWant = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: gameController.gameSettings.playgroundSize, longitudinalMeters: gameController.gameSettings.playgroundSize)
		let pixelWidth = mapView.convert(regionWeWant, toRectTo: viewMapOverlay).width
		contraintShapeViewSize.constant = pixelWidth
		viewMapOverlay.isHidden = false
		
		/* Also let’s update the position of the location brush view. */
		updateLocationBrushFrame()
		/* And show/hide the out of map arrows if needed */
		showOutOfMapArrows()
	}
	
}

/* ********************************
   MARK: - Game Controller Delegate
   ******************************** */

extension PlayViewController : GameControllerDelegate {
	
	func gameController(_ gameController: GameController, didChangeStatus newStatus: GameController.Status) {
		switch newStatus {
		case .idle: (/*nop*/)
		case .trackingUserPosition: (/*nop*/)
			
		case .playing(gameProgress: let gp, shapeView: _, mapView: _):
			UIApplication.shared.isIdleTimerDisabled = true
			
			mapView.isScrollEnabled = false
			mapView.showsUserLocation = false
			locationBrushView.isHidden = false
			buttonStartStopPlay.setTitle(NSLocalizedString("stop playing", comment: "Stop playing button title"), for: .normal)
			
			gridView.grid = gp.grid
			
			refreshGettingLocationTimerAndView()
			timerUpdateTimeLabels = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateTimeLabels(_:)), userInfo: nil, repeats: true)
			
		case .gameOver:
			UIApplication.shared.isIdleTimerDisabled = false
			
			timerUpdateTimeLabels?.invalidate()
			timerUpdateTimeLabels = nil
			
			/* Let’s show the game over view */
			viewGameOver.alpha = 0
			viewGameOver.frame = view.bounds
			view.addSubview(viewGameOver)
			UIView.animate(withDuration: c.animTimeShowGameOver, animations: {
				self.viewGameOver.alpha = 1
			})
		}
	}
	
	func gameController(_ gameController: GameController, failedToRetrieveLocation error: Error) {
		labelGPSAccuracy.text = NSLocalizedString("NA", comment: "")
		
		/* If there is an error retrieving the location of the user, there’s
		 * nothing more we can do, it is not possible to play! So we stop. */
		let alertController = UIAlertController(
			title: NSLocalizedString("cannot get location", comment: "Title of the cannot get location popup"),
			message: NSLocalizedString("cannot get location. aborting play", comment: "Message of the cannot get location popup"),
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { _ in
			self.quitPlayView(self)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
	func gameController(_ gameController: GameController, didGetNewLocation newLocation: CLLocation?) {
		if !gameController.isPlaying, !userHasMovedMap, let loc = newLocation {
			centerMap(locationCoordinate: loc.coordinate)
		}
		
		buttonStartStopPlay.isEnabled = true
		
		updateLocationBrushFrame()
		refreshGettingLocationTimerAndView()
		
		labelGPSAccuracy.text =
			newLocation.map{ String(format: NSLocalizedString("n m format", comment: "Format for \"10 m\""), Int($0.horizontalAccuracy.rounded())) } ??
			NSLocalizedString("NA", comment: "")
		
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
	}
	
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?) {
		locationBrushView?.heading = newHeading?.trueHeading
	}
	
	func gameController(_ gameController: GameController, didVisitCoordinate coordinate: Grid.Coordinate, newProgress: GameProgress) {
		gridView.addFilledSquare(at: coordinate)
		
		let percentCompleteStr = String(format: NSLocalizedString("percent complete format", comment: "Here, there is only a %d with the percent sign (%% for %) following"), newProgress.filledPercent)
		labelPercentFilled.text = percentCompleteStr
		wonLabelFilledPercent.text = percentCompleteStr
		
		wonLabelFilledSquareMeters.text = String(format: NSLocalizedString("n square meters format", comment: "Format for \"10 square meters\""), Int(newProgress.filledArea.rounded()))
	}
	
}

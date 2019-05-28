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



protocol PlayViewControllerDelegate : class {
	
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
		
		viewLoadingMap.alpha = 0
		viewMapOverlay.isHidden = true
		locationBrushView.isHidden = true
		shapeView.gameShape = gameController.gameSettings.gameShape
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
	
	@IBAction func centerMapToCurrentUserLocation(_ sender: AnyObject) {
		/* TODO */
//		let r = MKCoordinateRegion(center: coordinateForAnnotation, latitudinalMeters: gameProgress.settings.playgroundSize, longitudinalMeters: gameProgress.settings.playgroundSize)
//		mapView.setRegion(r, animated: true)
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
	
	private var mapMoving = false
	private var timerShowLoadingMap: Timer?
	
	private func updateLocationBrushFrame() {
		guard let loc = gameController.currentLocation else {return}
		
		let locationBrushRegion = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: gameController.gameSettings.paintingDiameter, longitudinalMeters: gameController.gameSettings.paintingDiameter)
		locationBrushView.frame = mapView.convert(locationBrushRegion, toRectTo: locationBrushView.superview!)
	}
	
}

/* *************************
   MARK: - Map View Delegate
   ************************* */

extension PlayViewController : VSOMapViewDelegate {
	
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
			
		case .gameOver:
			UIApplication.shared.isIdleTimerDisabled = false
			
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
		if !gameController.isPlaying {
			guard let loc = newLocation else {return}
			
			let mapToOverlayRatio: CGFloat
			if viewMapOverlay.frame.width > viewMapOverlay.frame.height {
				mapToOverlayRatio = mapView.frame.height / viewMapOverlay.frame.height
			} else {
				mapToOverlayRatio = mapView.frame.width / viewMapOverlay.frame.width
			}
			
			/* The overlay view is smaller than the map (by design) */
			let extendedPlaygroundSize = gameController.gameSettings.playgroundSize * CLLocationDistance(mapToOverlayRatio)
			
			let regionWeWant = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: extendedPlaygroundSize, longitudinalMeters: extendedPlaygroundSize)
//			let regionWeGet = mapView.regionThatFits(regionWeWant)
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
		}
		
		updateLocationBrushFrame()
	}
	
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?) {
		locationBrushView?.heading = newHeading?.trueHeading
	}
	
	func gameController(_ gameController: GameController, didVisitCoordinate coordinate: Grid.Coordinate, newProgress: GameProgress) {
		gridView.addFilledSquare(at: coordinate)
		
		let percentCompleteStr = String(format: NSLocalizedString("percent complete format from float", comment: "Here, there is only a %.0f with the percent sign (%% for %) following"), 100 * newProgress.filledArea/newProgress.fullArea)
		labelPercentFilled.text = percentCompleteStr
		wonLabelFilledPercent.text = percentCompleteStr
	}
	
}

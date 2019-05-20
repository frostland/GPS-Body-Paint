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
			newValue.delegate = self
		}
	}
	
	@IBOutlet var mapView: VSOMapView!
	@IBOutlet var viewShapeContainer: ShapeView!
	
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
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	/* ***************
	   MARK: - Actions
	   *************** */
	
	@IBAction func startOrStopPlaying(_ sender: UIButton) {
		if !gameController.isPlaying {
			gameController.startPlaying(in: viewShapeContainer, with: mapView)
		} else {
			gameController.stopPlaying()
		}
	}
	
	@IBAction func centerMapToCurrentUserLocation(_ sender: AnyObject) {
		/* TODO */
//		let r = MKCoordinateRegion(center: coordinateForAnnotation, latitudinalMeters: gameProgress.settings.playgroundSize, longitudinalMeters: gameProgress.settings.playgroundSize)
//		mapView.setRegion(r, animated: true)
	}
	
	@IBAction func stopPlaying(_ sender: AnyObject) {
		gameController.stopPlaying()
//		delegate?.playViewControllerDidFinish(self)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private let c = S.sp.constants
	private let s = S.sp.appSettings
	
	private var mapMoving = false
	private var timerShowLoadingMap: Timer?
	
}

/* *************************
   MARK: - Map View Delegate
   ************************* */

extension PlayViewController : VSOMapViewDelegate {
	
	func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
		buttonStartStopPlay.isEnabled = false
		
		guard timerShowLoadingMap == nil else {return}
		timerShowLoadingMap = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(PlayViewController.showViewLoadingMap(_:)), userInfo: nil, repeats: false)
	}
	
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
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
			self.stopPlaying(self)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
}

/* ********************************
   MARK: - Game Controller Delegate
   ******************************** */

extension PlayViewController : GameControllerDelegate {
	
	func gameController(_ gameController: GameController, didChangeStatus newStatus: GameController.Status) {
		switch newStatus {
		case .idle: (/*nop*/)
		case .trackingUserPosition:
			(/*nop*/)
			
		case .playing(gameProgress: let gp):
			buttonStartStopPlay.setTitle(NSLocalizedString("stop playing", comment: "Stop playing button title"), for: .normal)
			
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
			self.stopPlaying(self)
		}))
		present(alertController, animated: true, completion: nil)
	}
	
	func gameController(_ gameController: GameController, didGetNewLocation newLocation: CLLocation?) {
		if !gameController.isPlaying {
			guard let loc = newLocation else {return}
			
			/* TODO: Delta is a bit more than this, we must calculate how much. */
			let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: gameController.gameSettings.gridSize, longitudinalMeters: gameController.gameSettings.gridSize)
			mapView.setRegion(region, animated: true)
		} else {
		}
	}
	
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?) {
	}
	
	func gameController(_ gameController: GameController, didChangeProgress progress: GameProgress) {
		
	}
	
}

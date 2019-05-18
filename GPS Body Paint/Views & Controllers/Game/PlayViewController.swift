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
	@IBOutlet var viewShapePreview: ShapeView!
	
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
	
	@IBAction func startOrStopPlayingButtonTouchUpInside(_ sender: AnyObject) {
		gameController.startPlaying()
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
	
}

/* ********************************
   MARK: - Game Controller Delegate
   ******************************** */

extension PlayViewController : GameControllerDelegate {
	
	func gameController(_ gameController: GameController, didChangeStatus newStatus: GameController.Status) {
		switch newStatus {
		case .idle: ()
		case .trackingUserPosition: ()
		case .playing(gameProgress: let gp): ()
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
	}
	
	func gameController(_ gameController: GameController, didGetNewHeading newHeading: CLHeading?) {
	}
	
	func gameController(_ gameController: GameController, didChangeProgress progress: GameProgress) {
		
	}
	
}

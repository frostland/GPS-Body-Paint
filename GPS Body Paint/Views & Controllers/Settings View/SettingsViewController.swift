/*
 * SettingsViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation
import UIKit



class SettingsViewController : UITableViewController, UINavigationControllerDelegate, PlayViewControllerDelegate {
	
	var settings: Settings!
	
	@IBOutlet var labelLevelSize: UILabel!
	@IBOutlet var labelLevelDifficulty: UILabel!
	@IBOutlet var labelChallengeShape: UILabel!
	@IBOutlet var labelPlayingMode: UILabel!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		title = "GPS Body Paint"
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshUI()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		switch segue.identifier {
		case "Play"?:
			let ud = UserDefaults.standard
			let controller = segue.destination as! PlayViewController
			
			settings.gameShape = NSKeyedUnarchiver.unarchiveObject(with: ud.data(forKey: Constants.UserDefault.gameShape)!)! as! GameShape
			settings.playgroundSize = ud.double(forKey: Constants.UserDefault.levelSize)
			settings.gridSize = 3
			settings.playingMode = PlayingMode(rawValue: ud.integer(forKey: Constants.UserDefault.playingMode))!
			settings.playingTime = ud.double(forKey: Constants.UserDefault.playingTime)
			settings.playingFillPercentToDo = ud.integer(forKey: Constants.UserDefault.playingFillPercentage)
			settings.userLocationDiameter = 10 - CLLocationDistance(ud.integer(forKey: Constants.UserDefault.paintingSize))*1.9
			
			controller.gameProgress = GameProgress(settings: settings)
			controller.delegate = self
			
		default: (/*nop*/)
		}
	}
	
	/* Hacky… */
	func doDismissModalViewControllerAnimated() {
//		NSLog("doDismissModalViewControllerAnimated called")
		
		guard presentedViewController != nil else {return}
		dismiss(animated: true, completion: nil)
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: { [weak self] in self?.doDismissModalViewControllerAnimated() })
	}
	
	func playViewControllerDidFinish(_ controller: PlayViewController) {
		doDismissModalViewControllerAnimated()
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private func refreshUI() {
		labelLevelSize.text = LevelSizeViewController.localizedSettingValue
		labelLevelDifficulty.text = LevelDifficultyViewController.localizedSettingValue
		labelChallengeShape.text = ChallengeShapeViewController.localizedSettingValue
		labelPlayingMode.text = PlayingModeViewController.localizedSettingValue
	}
	
}

/*
 * LevelDifficultyViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import UIKit



class LevelDifficultyViewController : UIViewController {
	
	@objc
	static var localizedSettingValue: String {
		switch UserDefaults.standard.integer(forKey: Constants.UserDefault.paintingSize) {
		case 0: return NSLocalizedString("big",    comment: "Big painting size")
		case 1: return NSLocalizedString("medium", comment: "Medium painting size")
		case 2: return NSLocalizedString("small",  comment: "Small painting size")
		default: fatalError("Unknown painting size \(UserDefaults.standard.integer(forKey: Constants.UserDefault.paintingSize))")
		}
	}
	
	@IBOutlet var segmentedControlPaintingSize: UISegmentedControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		segmentedControlPaintingSize.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Constants.UserDefault.paintingSize)
		
	}
	
	@IBAction func levelPaintingSizeChanged(_ sender: AnyObject) {
		UserDefaults.standard.set(segmentedControlPaintingSize.selectedSegmentIndex, forKey: Constants.UserDefault.paintingSize)
	}
	
}

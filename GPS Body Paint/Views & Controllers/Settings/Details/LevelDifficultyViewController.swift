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
	
	static var localizedSettingValue: String {
		switch S.sp.appSettings.paintingSize {
		case .small:  return NSLocalizedString("big",    comment: "Big painting size")
		case .medium: return NSLocalizedString("medium", comment: "Medium painting size")
		case .big:    return NSLocalizedString("small",  comment: "Small painting size")
		}
	}
	
	@IBOutlet var segmentedControlPaintingSize: UISegmentedControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		segmentedControlPaintingSize.selectedSegmentIndex = min(s.paintingSize.rawValue, segmentedControlPaintingSize.numberOfSegments)
	}
	
	@IBAction func levelPaintingSizeChanged(_ sender: AnyObject) {
		let i = segmentedControlPaintingSize.selectedSegmentIndex
		guard let newSize = PaintingSize(rawValue: i) else {
			NSLog("*** Warning: Invalid segmented control index for painting size %ld", i)
			return
		}
		s.paintingSize = newSize
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	/* Dependencies */
	private let s = S.sp.appSettings
	
}

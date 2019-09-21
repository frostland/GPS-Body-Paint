/*
 * LevelSizeViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreLocation
import Foundation
import UIKit



class LevelSizeViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	static var localizedSettingValue: String {
		return localizedString(from: S.sp.appSettings.levelSize)
	}
	
	@IBOutlet var pickerView: UIPickerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let size = s.levelSize
		let row = distances.enumerated().sorted(by: { abs($0.element - size) < abs($1.element - size) }).first!.offset
		pickerView.selectRow(row, inComponent: 0, animated: false)
	}
	
	/* *************************************
	   MARK: - Picker Data Source & Delegate
	   ************************************* */
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return distances.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		s.levelSize = distances[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return LevelSizeViewController.localizedString(from: distances[row])
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private static func localizedString(from distance: CLLocationDistance) -> String {
		return String(format: NSLocalizedString("n meters format", comment: ""), Int(distance.rounded()))
	}
	
	/* Dependencies */
	private let s = S.sp.appSettings
	
	private let distances: [CLLocationDistance] = [25, 50, 75]
	
}

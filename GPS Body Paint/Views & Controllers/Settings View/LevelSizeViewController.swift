/*
 * LevelSizeViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation



class LevelSizeViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	@objc
	static var localizedSettingValue: String {
		return localizedString(from: UserDefaults.standard.integer(forKey: VSO_UDK_LEVEL_SIZE))
	}
	
	@IBOutlet var pickerView: UIPickerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let s = UserDefaults.standard.integer(forKey: VSO_UDK_LEVEL_SIZE)
		let r: Int
		switch s {
		case 25: r = 0
		case 50: r = 1
		case 75: r = 2
		default: r = 0
		}
		pickerView.selectRow(r, inComponent: 0, animated: false)
	}
	
	/* *************************************
	   MARK: - Picker Data Source & Delegate
	   ************************************* */
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 3
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		UserDefaults.standard.set(nMeters(from: row), forKey: VSO_UDK_LEVEL_SIZE)
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return LevelSizeViewController.localizedString(from: nMeters(from: row))
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private static func localizedString(from nMeters: Int) -> String {
		return String(format: NSLocalizedString("n meters format", comment: ""), nMeters)
	}
	
	private func nMeters(from pickerRow: Int) -> Int {
		switch pickerRow {
		case 0: return 25
		case 1: return 50
		case 2: return 75
		default: fatalError("Invalid row \(pickerRow) for level size settings")
		}
	}
	
}

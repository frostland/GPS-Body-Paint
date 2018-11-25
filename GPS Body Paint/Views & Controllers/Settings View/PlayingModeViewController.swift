/*
 * PlayingModeViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import UIKit



class PlayingModeViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {
	
	@objc
	static var localizedSettingValue: String {
		return playingMode(from: UserDefaults.standard.integer(forKey: Constants.UserDefault.playingMode))
	}
	
	@IBOutlet var pickerView: UIPickerView!
	@IBOutlet var datePicker: UIDatePicker!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let ud = UserDefaults.standard
		datePicker.countDownDuration = ud.double(forKey: Constants.UserDefault.playingTime)
		
		let r: Int
		switch ud.integer(forKey: Constants.UserDefault.playingFillPercentage) {
		case 100: r = 0
		case  90: r = 1
		case  75: r = 2
		case  60: r = 3
		case  50: r = 4
		default: r = 2
		}
		pickerView.selectRow(r, inComponent: 0, animated: false)
		
		switch PlayingMode(rawValue: ud.integer(forKey: Constants.UserDefault.playingMode)) {
		case .fillIn?:    pickerView.alpha = 1; datePicker.alpha = 0
		case .timeLimit?: pickerView.alpha = 0; datePicker.alpha = 1
		default: fatalError("Unknown playing mode \(ud.integer(forKey: Constants.UserDefault.playingMode))")
		}
	}
	
	@IBAction func timeChanged(_ sender: AnyObject) {
		if datePicker.countDownDuration < 60 {datePicker.countDownDuration = 0}
		UserDefaults.standard.set(datePicker.countDownDuration, forKey: Constants.UserDefault.playingTime)
	}
	
	/* *****************************************
	   MARK: - Table View Data Source & Delegate
	   ***************************************** */
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PlayingModeCell", for: indexPath)
		
		let r = indexPath[1]
		let m = UserDefaults.standard.integer(forKey: Constants.UserDefault.playingMode)
		if m == r {cell.accessoryType = .checkmark}
		else      {cell.accessoryType = .none}
		cell.textLabel?.text = PlayingModeViewController.playingMode(from: r)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let r = indexPath[1]
		UserDefaults.standard.set(r, forKey: Constants.UserDefault.playingMode)
		UIView.animate(withDuration: 0.25, animations: {
			switch PlayingMode(rawValue: r) {
			case .fillIn?:    self.pickerView.alpha = 1; self.datePicker.alpha = 0
			case .timeLimit?: self.pickerView.alpha = 0; self.datePicker.alpha = 1
			default: fatalError("Unknown playing mode \(r)")
			}
		})
		
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadData()
	}
	
	/* ******************************************
      MARK: - Picker View Data Source & Delegate
	   ****************************************** */
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 5
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		UserDefaults.standard.set(nPercent(from: row), forKey: Constants.UserDefault.playingFillPercentage)
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return String(format: "%lu%%", nPercent(from: row))
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private static func playingMode(from i: Int) -> String {
		switch i {
		case 0: return NSLocalizedString("fill in",    comment: "Fill in play mode setting label")
		case 1: return NSLocalizedString("time limit", comment: "Time limit play mode setting label")
		default: fatalError("Invalid playing mode \(i)")
		}
	}
	
	private func nPercent(from pickerRow: Int) -> Int {
		switch pickerRow {
		case 0: return 100
		case 1: return 90
		case 2: return 75
		case 3: return 60
		case 4: return 50
		default: fatalError("Invalid picker row in settings for the percentage of fill-in")
		}
	}
	
}

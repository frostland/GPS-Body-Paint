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
	
	static var localizedSettingValue: String {
		return playingMode(from: S.sp.appSettings.playingMode.id)
	}
	
	@IBOutlet var pickerView: UIPickerView!
	@IBOutlet var datePicker: UIDatePicker!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		datePicker.countDownDuration = s.playingModeTimeValue
		
		let percentage = s.playingModeFillValue
		let row = percentages.enumerated().sorted(by: { abs($0.element - percentage) < abs($1.element - percentage) }).first!.offset
		pickerView.selectRow(row, inComponent: 0, animated: false)
		
		updateTimerAndPercentagesInputAlpha()
	}
	
	@IBAction func timeChanged(_ sender: AnyObject) {
		if datePicker.countDownDuration < 60 {datePicker.countDownDuration = 0}
		s.playingModeTimeValue = datePicker.countDownDuration
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
		let m = s.playingMode
		if m.id == r {cell.accessoryType = .checkmark}
		else         {cell.accessoryType = .none}
		cell.textLabel?.text = PlayingModeViewController.playingMode(from: r)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let r = indexPath[1]
		s.playingModeId = r
		
		UIView.animate(withDuration: 0.25, animations: updateTimerAndPercentagesInputAlpha)
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
		return percentages.count
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		s.playingModeFillValue = percentages[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return String(format: "%lu%%", percentages[row])
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private static func playingMode(from playingModeId: Int) -> String {
		switch playingModeId {
		case PlayingMode.fillInId:    return NSLocalizedString("fill in",    comment: "Fill in play mode setting label")
		case PlayingMode.timeLimitId: return NSLocalizedString("time limit", comment: "Time limit play mode setting label")
		default: fatalError("Invalid playing mode id \(playingModeId)")
		}
	}
	
	/* Dependencies */
	private let s = S.sp.appSettings
	
	private let percentages = [100, 90, 75, 60, 50]
	
	private func updateTimerAndPercentagesInputAlpha() {
		switch s.playingMode {
		case .fillIn:    self.pickerView.alpha = 1; self.datePicker.alpha = 0
		case .timeLimit: self.pickerView.alpha = 0; self.datePicker.alpha = 1
		}
	}
	
}

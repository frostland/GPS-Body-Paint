/*
 * AppSettings.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreLocation
import CoreGraphics
import Foundation



class AppSettings {
	
	let ud: UserDefaults
	
	init(userDefaults: UserDefaults = .standard) {
		ud = userDefaults
	}
	
	func registerDefaultSettings() {
		/* Registering default user defaults */
		let defaultValues: [SettingsKey: Any?] = [
			.firstLaunch:             true,
			.paintingSize:            PaintingSize.medium.rawValue,
			.levelSize:               CLLocationDistance(25),
			.playingModeId:           PlayingMode.fillInId,
			.playingModeFillValue:    75,
			.playingModeTimeValue:    TimeInterval(5*60),
			.gameShapeId:             BuiltInGameShapeId.square.rawValue,
			.gameShapePolygon:        nil,
			.warnOnMapLoadingFailure: true
		]
		
		/* Let’s make sure all the cases have been registered in the defaults. */
		for k in SettingsKey.allCases {
			switch defaultValues[k] {
			case .none: fatalError("No default value for default key “\(k)”")
			case .some: (/*nop*/)
			}
		}
		
		var defaultValuesNoNull = [String: Any]()
		for (key, val) in defaultValues {
			guard let val = val else {continue}
			defaultValuesNoNull[key.rawValue] = val
		}
		ud.register(defaults: defaultValuesNoNull)
	}
	
	func forceSettingsSynchronization() {
		ud.synchronize()
	}
	
	/* **************************
	   MARK: - Settings Accessors
	   ************************** */
	
	var firstLaunch: Bool {
		get {return ud.bool(forKey: SettingsKey.firstLaunch.rawValue)}
		set {ud.set(newValue, forKey: SettingsKey.firstLaunch.rawValue)}
	}
	
	var gameShape: GameShape {
		get {
			if let idRaw = ud.value(forKey: SettingsKey.gameShapeId.rawValue) as? NSNumber, let id = BuiltInGameShapeId(rawValue: idRaw.intValue) {
				return GameShape(shapeId: id)
			} else if let polygon = ud.array(forKey: SettingsKey.gameShapePolygon.rawValue) as? [CGPoint] {
				return GameShape(polygon: polygon)
			} else {
				return GameShape(shapeId: .square)
			}
		}
		set {
			if let id = newValue.builtinGameShapeId {
				ud.set(id.rawValue, forKey: SettingsKey.gameShapeId.rawValue)
				ud.removeObject(forKey: SettingsKey.gameShapePolygon.rawValue)
			} else {
				ud.set(newValue.polygon, forKey: SettingsKey.gameShapePolygon.rawValue)
				ud.removeObject(forKey: SettingsKey.gameShapeId.rawValue)
			}
		}
	}
	
	var paintingSize: PaintingSize {
		get {return PaintingSize(rawValue: ud.integer(forKey: SettingsKey.paintingSize.rawValue)) ?? .medium}
		set {ud.set(newValue.rawValue, forKey: SettingsKey.paintingSize.rawValue)}
	}
	
	var levelSize: CLLocationDistance {
		get {return ud.double(forKey: SettingsKey.levelSize.rawValue)}
		set {ud.set(newValue, forKey: SettingsKey.levelSize.rawValue)}
	}
	
	/** The playing mode id in the user defaults. **NOT** guaranteed to make
	sense (no check for invalid value in user defaults). */
	var playingModeId: Int {
		get {return ud.integer(forKey: SettingsKey.playingModeId.rawValue)}
		set {
			switch newValue {
			case PlayingMode.timeLimitId: ud.set(newValue,             forKey: SettingsKey.playingModeId.rawValue)
			default:                      ud.set(PlayingMode.fillInId, forKey: SettingsKey.playingModeId.rawValue)
			}
		}
	}
	
	var playingModeFillValue: Int {
		get {
			let fillValue = ud.integer(forKey: SettingsKey.playingModeFillValue.rawValue)
			if fillValue > 0 && fillValue <= 100 {return fillValue}
			else                                 {return 75}
		}
		set {ud.set(newValue, forKey: SettingsKey.playingModeFillValue.rawValue)}
	}
	
	var playingModeTimeValue: TimeInterval {
		get {
			let timeValue = ud.double(forKey: SettingsKey.playingModeTimeValue.rawValue)
			if timeValue.sign == .plus {return timeValue}
			else                       {return 5*60}
		}
		set {ud.set(newValue, forKey: SettingsKey.playingModeTimeValue.rawValue)}
	}
	
	var warnOnMapLoadingFailure: Bool {
		get {return ud.bool(forKey: SettingsKey.warnOnMapLoadingFailure.rawValue)}
		set {ud.set(newValue, forKey: SettingsKey.warnOnMapLoadingFailure.rawValue)}
	}
	
	/* Playing mode convenience */
	
	var playingMode: PlayingMode {
		/* We assume the playing mode stored in the defaults is a fill mode if not
		 * time limit, because it’s the default. */
		switch playingModeId {
		case PlayingMode.timeLimitId: return .timeLimit(duration: playingModeTimeValue)
		default:                      return .fillIn(percentGoal: playingModeFillValue)
		}
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private enum SettingsKey : String, CaseIterable {
		
		case firstLaunch             = "First Launch"
		
		case gameShapeId             = "VSO Saved Game Shape Id"
		case gameShapePolygon        = "VSO Saved Game Shape Polygon"
		case paintingSize            = "VSO Level Painting Size"
		case levelSize               = "VSO Level Size"
		
		case playingModeId           = "VSO Playing Mode"
		case playingModeFillValue    = "VSO Playing Mode Fill In - Chosen Percentage"
		case playingModeTimeValue    = "VSO Playing Mode Time Limit - Time Chosen"
		
		case warnOnMapLoadingFailure = "VSO Warn On Map Loading Failure"
		
	}
	
}

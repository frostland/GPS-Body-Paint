/*
 * AppDelegate.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import UIKit



@UIApplicationMain
class AppDelegate : NSObject, UIApplicationDelegate {
	
	var window: UIWindow?
	
	override init() {
		super.init()
		
		UserDefaults.standard.register(defaults: [
			Constants.UserDefault.firstLaunch:           true,
			Constants.UserDefault.paintingSize:          1,
			Constants.UserDefault.levelSize:             25,
			Constants.UserDefault.playingMode:           PlayingMode.fillIn.rawValue,
			Constants.UserDefault.playingTime:           5*60,
			Constants.UserDefault.playingFillPercentage: 75,
			Constants.UserDefault.gameShape:             NSKeyedArchiver.archivedData(withRootObject: GameShape(type: .square))
		])
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		((window!.rootViewController! as! UINavigationController).viewControllers.first! as! SettingsViewController).settings = Settings()
		return true
	}
	
}

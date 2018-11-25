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
			VSO_UDK_FIRST_LAUNCH:            true,
			VSO_UDK_LEVEL_PAINTING_SIZE:     1,
			VSO_UDK_LEVEL_SIZE:              25,
			VSO_UDK_PLAYING_MODE:            VSOPlayingMode.fillIn.rawValue,
			VSO_UDK_PLAYING_TIME:            5*60,
			VSO_UDK_PLAYING_FILL_PERCENTAGE: 75,
			VSO_UDK_GAME_SHAPE:              NSKeyedArchiver.archivedData(withRootObject: GameShape(type: .square))
		])
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		((window!.rootViewController! as! UINavigationController).viewControllers.first! as! SettingsViewController).settings = Settings()
		return true
	}
	
}

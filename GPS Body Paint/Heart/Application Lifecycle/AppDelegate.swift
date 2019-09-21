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
	
	static private(set) var sharedAppDelegate: AppDelegate!
	
	var window: UIWindow?
	
	override init() {
		super.init()
		
		if AppDelegate.sharedAppDelegate == nil {AppDelegate.sharedAppDelegate = self}
		else                                    {fatalError("The App Delegate must be instantiated only once!")}
		
		settings.registerDefaultSettings()
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	/* Dependencies */
	private let settings = S.sp.appSettings
	
}

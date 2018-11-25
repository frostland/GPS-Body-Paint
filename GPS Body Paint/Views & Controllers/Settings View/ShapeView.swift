/*
 * ShapeView.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import UIKit



class ShapeView : UIView {
	
	var gameShape: GameShape? {
		didSet {setNeedsDisplay()}
	}
	
	override func draw(_ rect: CGRect) {
		guard let c = UIGraphicsGetCurrentContext() else {return}
		gameShape?.draw(in: bounds, context: c)
	}
	
}

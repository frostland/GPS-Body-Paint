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
		guard let gameShape = gameShape else {return}
		guard let context = UIGraphicsGetCurrentContext() else {return}
		
		context.saveGState()
		
		context.setLineWidth(0.5)
		
		context.setStrokeColor(UIColor.red.cgColor)
		context.setFillColor(UIColor.red.withAlphaComponent(0.15).cgColor)
		
		context.addPath(gameShape.pathForDrawing(in: rect))
		context.drawPath(using: .fillStroke)
		
		context.restoreGState()
	}
	
}

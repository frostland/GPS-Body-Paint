/*
 * GridView.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/18.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import Foundation
import UIKit



class GridView : UIView {
	
	var grid: Grid? {
		didSet {setNeedsDisplay()}
	}
	
	override func draw(_ rect: CGRect) {
		guard let grid = grid else {return}
		guard let c = UIGraphicsGetCurrentContext() else {return}
		
		c.saveGState()
		
//		c.addPath(gameShape.pathForDrawing(in: bounds))
//		c.clip()
		
		c.setStrokeColor(UIColor.black.withAlphaComponent(0.5).cgColor)
		c.addPath(grid.lines)
		c.strokePath()
		
		c.restoreGState()
	}
	
}

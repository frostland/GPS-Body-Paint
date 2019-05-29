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
		didSet {
			filledSquareViews.values.forEach{ $0.removeFromSuperview() }
			filledSquareViews.removeAll()
			
			if let g = grid {
				let mask = CAShapeLayer()
				mask.path = g.path
				layer.mask = mask
			} else {
				layer.mask = nil
			}
			
			setNeedsDisplay()
		}
	}
	
	override func draw(_ rect: CGRect) {
		guard let grid = grid else {return}
		guard let c = UIGraphicsGetCurrentContext() else {return}
		
		c.saveGState()
		
		c.setStrokeColor(UIColor.black.withAlphaComponent(0.5).cgColor)
		c.addPath(grid.lines)
		c.strokePath()
		
		c.restoreGState()
	}
	
	func addFilledSquare(at coordinate: Grid.Coordinate) {
		guard let grid = grid else {return}
		guard filledSquareViews[coordinate] == nil else {return}
		
		let frame = grid.square(at: coordinate)
		let v = UIView(frame: frame)
		v.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 0.7)
		v.alpha = 0
		addSubview(v)
		
		UIView.animate(withDuration: 0.5, animations: {
			v.alpha = 1
		})
		
		filledSquareViews[coordinate] = v
	}

	private var filledSquareViews = [Grid.Coordinate: UIView]()
	
}

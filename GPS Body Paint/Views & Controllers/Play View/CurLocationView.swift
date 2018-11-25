/*
 * CurLocationView.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreGraphics
import CoreLocation
import Foundation
import UIKit

private let USER_LOCATION_VIEW_CENTER_DOT_SIZE = CGFloat(5)



class CurLocationView : UIView {
	
	/* Should be optional. Will be once we’re full Swift! Also should be in radian… currently is in degrees. */
	@objc var heading = CLLocationDirection(-1) {
		didSet {setNeedsDisplay()}
	}
	@objc var precision = CGFloat(0) {
		didSet {let f = frame; frame = f}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		isOpaque = false
		backgroundColor = .clear
		contentMode = .redraw
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Unsupported init method")
	}
	
	override var frame: CGRect {
		set {
			/* Converted straight from ObjC. But this is BAD! */
			var f = newValue
			let s = max(USER_LOCATION_VIEW_CENTER_DOT_SIZE, precision + 3)
			
			f.origin.x += (f.size.width  - s)/2
			f.origin.y += (f.size.height - s)/2
			f.size.width = s
			f.size.height = s
			
			super.frame = f
		}
		get {return super.frame}
	}
	
	override func draw(_ rect: CGRect) {
//		NSLog("Drawing a CurLocationView with rect: %@", NSStringFromCGRect(rect));
		guard let c = UIGraphicsGetCurrentContext() else {return}
		
		let center = CGPoint(x: rect.midX, y: rect.midY)
		
		if heading >= 0 {
			c.concatenate(CGAffineTransform(translationX: center.x, y: center.y))
			c.concatenate(CGAffineTransform(rotationAngle: CGFloat(-2*CLLocationDirection.pi*(heading/360))))
			c.concatenate(CGAffineTransform(translationX: -center.x, y: -center.y))
		}
		
		let precisionRect = CGRect(x: center.x - precision/2, y: center.y - precision/2, width: precision, height: precision)
		let color = UIColor(red: 89/255, green: 52/255, blue: 22/255, alpha: 1)
		c.setFillColor(color.withAlphaComponent(0.3).cgColor)
		c.setStrokeColor(color.cgColor)
		c.setLineWidth(1)
		
		c.fillEllipse(in: precisionRect)
		c.strokeEllipse(in: precisionRect)
		
		if heading >= 0 {
			/* Heading is defined. Drawing the arrow. */
			let r = precision/2
			c.move(to: CGPoint(x: center.x, y: center.y - r))
			c.addLine(to: CGPoint(x: center.x + cos(  CGFloat.pi/3)*r, y: center.y + sin(  CGFloat.pi/3)*r))
			c.addLine(to: CGPoint(x: center.x + cos(2*CGFloat.pi/3)*r, y: center.y + sin(2*CGFloat.pi/3)*r))
			c.addLine(to: CGPoint(x: center.x,                         y: center.y - r))
			
			c.setFillColor(UIColor(white: 0.7, alpha: 0.8).cgColor)
			c.drawPath(using: .fillStroke)
		} else {
			c.setFillColor(color.cgColor)
			c.fillEllipse(in: CGRect(x: center.x - USER_LOCATION_VIEW_CENTER_DOT_SIZE/2, y: center.y - USER_LOCATION_VIEW_CENTER_DOT_SIZE/2, width: USER_LOCATION_VIEW_CENTER_DOT_SIZE, height: USER_LOCATION_VIEW_CENTER_DOT_SIZE))
		}
	}
	
}

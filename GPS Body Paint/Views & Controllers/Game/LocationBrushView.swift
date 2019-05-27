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



class LocationBrushView : UIView {
	
	var brushSizeInPixels: CGFloat {
		get {return frame.width}
		set {frame = CGRect(origin: frame.origin, size: CGSize(width: newValue, height: newValue)); setNeedsDisplay()}
	}
	
	/** In degree! Because CoreLocation sends the heading in degrees… */
	var heading: CLLocationDirection? {
		didSet {setNeedsDisplay()}
	}
	
	override init(frame: CGRect) {
		fatalError("Unsupported init method")
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		isOpaque = false
		contentMode = .redraw
		backgroundColor = .clear
	}
	
	override func draw(_ rect: CGRect) {
//		NSLog("Drawing a CurLocationView with rect: %@", NSStringFromCGRect(rect));
		guard let c = UIGraphicsGetCurrentContext() else {return}
		
		let strokeWidth = CGFloat(1)
		
		let circleSize = max(0, min(bounds.width - strokeWidth*2, bounds.height - strokeWidth*2))
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		let circleBounds = CGRect(x: center.x - circleSize/2, y: center.y - circleSize/2, width: circleSize, height: circleSize)
		
		if let heading = heading {
			c.concatenate(CGAffineTransform(translationX: center.x, y: center.y))
			c.concatenate(CGAffineTransform(rotationAngle: CGFloat(2*CLLocationDirection.pi*(heading/360))))
			c.concatenate(CGAffineTransform(translationX: -center.x, y: -center.y))
		}
		
		let color = UIColor(red: 89/255, green: 52/255, blue: 22/255, alpha: 1)
		c.setFillColor(color.withAlphaComponent(0.3).cgColor)
		c.setStrokeColor(color.cgColor)
		c.setLineWidth(strokeWidth)
		
		c.fillEllipse(in: circleBounds)
		c.strokeEllipse(in: circleBounds)
		
		if heading != nil {
			/* Heading is defined. Drawing the arrow. */
			let r = circleSize/2
			c.move(to: CGPoint(x: center.x, y: center.y - r))
			c.addLine(to: CGPoint(x: center.x + cos(  CGFloat.pi/3)*r, y: center.y + sin(  CGFloat.pi/3)*r))
			c.addLine(to: CGPoint(x: center.x + cos(2*CGFloat.pi/3)*r, y: center.y + sin(2*CGFloat.pi/3)*r))
			c.addLine(to: CGPoint(x: center.x,                         y: center.y - r))
			
			c.setFillColor(UIColor(white: 0.7, alpha: 0.8).cgColor)
			c.drawPath(using: .fillStroke)
		} else {
			c.setFillColor(color.cgColor)
			c.fillEllipse(in: CGRect(x: center.x - centerDotSize/2, y: center.y - centerDotSize/2, width: centerDotSize, height: centerDotSize))
		}
	}
	
	private let centerDotSize = CGFloat(5)
	
}

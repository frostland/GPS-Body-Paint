/*
 * Quadrilateral.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/2/17.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreGraphics
import Foundation



struct Quadrilateral {
	
	var p0, p1, p2, p3: CGPoint
	
	var l0: CGPath {let p = CGMutablePath(); p.addLines(between: [p0, p1]); return p}
	var l1: CGPath {let p = CGMutablePath(); p.addLines(between: [p1, p2]); return p}
	var l2: CGPath {let p = CGMutablePath(); p.addLines(between: [p2, p3]); return p}
	var l3: CGPath {let p = CGMutablePath(); p.addLines(between: [p3, p0]); return p}
	
	func area() -> CGFloat {
		return (
			areaOfTriangle(p0, p1, p3) +
			areaOfTriangle(p1, p2, p3)
		)
	}
	
	subscript(index: Int) -> CGPoint {
		switch index {
		case 0: return p0
		case 1: return p1
		case 2: return p2
		case 3: return p3
		default: fatalError("Invalid quadrilateral index \(index)")
		}
	}
	
	private func areaOfTriangle(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
		let dx = p0.x - p1.x
		let dy = p0.y - p1.y
		
		if dx.isZero {
			return abs(p1.y - p0.y) * abs(p2.x - p0.x) / 2
		}
		
		let a = -dy/dx
		let b = -a*p0.x - p0.y
		
		return (sqrt(dx*dx + dy*dy) * (abs(a*p2.x + p2.y + b) / sqrt(a*a + 1)))/2
	}
	
}

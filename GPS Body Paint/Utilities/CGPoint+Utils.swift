/*
 * CGPoint+Utils.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/27.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreGraphics



extension CGPoint {
	
	func distance(from otherPoint: CGPoint) -> CGFloat {
		let p1 = self
		let p2 = otherPoint
		let dx = p2.x - p1.x
		let dy = p2.y - p1.y
		return (dx * dx + dy * dy).squareRoot()
	}
	
	func pointMoving(along normalizedVector: CGPoint, distance: CGFloat) -> CGPoint {
		return CGPoint(
			x: x + distance * normalizedVector.x,
			y: y + distance * normalizedVector.y
		)
	}
	
}

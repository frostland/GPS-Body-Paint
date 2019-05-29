/*
 * Segment.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/5/27.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import CoreGraphics



struct Segment {
	
	var p0: CGPoint
	var p1: CGPoint
	
	func normalizedCounterClockwisePerpendicularVector() -> CGPoint? {
		let baseVector = CGPoint(x: p0.x - p1.x, y: p0.y - p1.y)
		let baseVectorLength = (baseVector.x * baseVector.x + baseVector.y * baseVector.y).squareRoot()
		
		guard baseVectorLength > 0.000001 else {return nil}
		
		/* From https://gamedev.stackexchange.com/a/113394 (Yeah I suck at maths…) */
		return CGPoint(x: -baseVector.y / baseVectorLength, y: baseVector.x / baseVectorLength)
	}
	
	/* The segment will be moved along a perpendicular vector to the (p0, p1)
	 * vector, with a counter-clockwise rotation (arbitrarily, because it’s the
	 * “natural” direction in maths).
	 *
	 * If the original segment is a zero length segment, this method will return
	 * a zero length segment moved along the arbitrary (1,1) vector with the
	 * given distance. */
	func parallelSegment(distance: CGFloat) -> Segment {
		let perpendicularNormalizedVector =
			normalizedCounterClockwisePerpendicularVector() ??
			CGPoint(x: CGFloat(0.5).squareRoot(), y: CGFloat(0.5).squareRoot())
		
		return Segment(
			p0: p0.pointMoving(along: perpendicularNormalizedVector, distance: distance),
			p1: p1.pointMoving(along: perpendicularNormalizedVector, distance: distance)
		)
	}
	
}

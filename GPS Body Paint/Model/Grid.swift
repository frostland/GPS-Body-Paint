/*
 * Grid.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/2/16.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import Foundation
import CoreGraphics



struct Grid {
	
	struct Coordinate : Hashable {
		
		var col, row: Int
		
	}
	
	let path: CGPath
	let area: CGFloat
	
	let lines: CGPath
	let gridSize: CGFloat
	let nCols, nRows: Int
	
	init(shape: GameShape, in rect: CGRect, gridSize s: CGFloat) {
//		let computationStartDate = Date()
		gridSize = s
		path = shape.pathForDrawing(in: rect)
		let center = CGPoint(x: rect.midX, y: rect.midY)
		
		/* *** Computing the number of colums and rows to store *** */
		
		let approximateColsCount = Int((rect.width  / gridSize).rounded(.up))
		let approximateRowsCount = Int((rect.height / gridSize).rounded(.up))
		assert(CGFloat(approximateColsCount)*s >= rect.width)
		assert(CGFloat(approximateRowsCount)*s >= rect.height)
		
		if approximateColsCount % 2 == 0 {nCols = approximateColsCount + 1}
		else                             {nCols = approximateColsCount}
		if approximateRowsCount % 2 == 0 {nRows = approximateRowsCount + 1}
		else                             {nRows = approximateRowsCount}
		
		/* *** Computing the quadrilaterals in the grid *** */
		
		var cellsBuilding = [Quadrilateral?]()
		xStart = center.x - gridSize*(CGFloat(nCols)/2)
		yStart = center.y - gridSize*(CGFloat(nRows)/2)
		for y in stride(from: yStart, to: rect.maxY, by: gridSize) {
			for x in stride(from: xStart, to: rect.maxX, by: gridSize) {
				let tlCorner = CGPoint(x: x,            y: y)
				let trCorner = CGPoint(x: x + gridSize, y: y)
				let blCorner = CGPoint(x: x,            y: y + gridSize)
				let brCorner = CGPoint(x: x + gridSize, y: y + gridSize)
				let tlCornerContained = path.contains(tlCorner)
				let trCornerContained = path.contains(trCorner)
				let brCornerContained = path.contains(brCorner)
				let blCornerContained = path.contains(blCorner)
				
				guard tlCornerContained || trCornerContained || brCornerContained || blCornerContained else {
					cellsBuilding.append(nil)
					continue
				}
				
				let tlFinalCorner: CGPoint
				let trFinalCorner: CGPoint
				let blFinalCorner: CGPoint
				let brFinalCorner: CGPoint
				
				if tlCornerContained {tlFinalCorner = tlCorner}
				else {
					if      trCornerContained {tlFinalCorner = Grid.nearestPoint(in: path, from: tlCorner, direction: trCorner)}
					else if blCornerContained {tlFinalCorner = Grid.nearestPoint(in: path, from: tlCorner, direction: blCorner)}
					else if brCornerContained {tlFinalCorner = Grid.nearestPoint(in: path, from: tlCorner, direction: brCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				if trCornerContained {trFinalCorner = trCorner}
				else {
					if      tlCornerContained {trFinalCorner = Grid.nearestPoint(in: path, from: trCorner, direction: tlCorner)}
					else if brCornerContained {trFinalCorner = Grid.nearestPoint(in: path, from: trCorner, direction: brCorner)}
					else if blCornerContained {trFinalCorner = Grid.nearestPoint(in: path, from: trCorner, direction: blCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				if brCornerContained {brFinalCorner = brCorner}
				else {
					if      blCornerContained {brFinalCorner = Grid.nearestPoint(in: path, from: brCorner, direction: blCorner)}
					else if trCornerContained {brFinalCorner = Grid.nearestPoint(in: path, from: brCorner, direction: trCorner)}
					else if tlCornerContained {brFinalCorner = Grid.nearestPoint(in: path, from: brCorner, direction: tlCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				if blCornerContained {blFinalCorner = blCorner}
				else {
					if      brCornerContained {blFinalCorner = Grid.nearestPoint(in: path, from: blCorner, direction: brCorner)}
					else if tlCornerContained {blFinalCorner = Grid.nearestPoint(in: path, from: blCorner, direction: tlCorner)}
					else if trCornerContained {blFinalCorner = Grid.nearestPoint(in: path, from: blCorner, direction: trCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				
				cellsBuilding.append(Quadrilateral(p0: tlFinalCorner, p1: trFinalCorner, p2: brFinalCorner, p3: blFinalCorner))
			}
		}
		cells = cellsBuilding
		
		/* *** Computing the horizontal and vertical lines *** */
		
		let pathBoundingBox = path.boundingBoxOfPath
		
		let linesBuilding = CGMutablePath()
		stride(from: xStart + gridSize, to: rect.maxX, by: gridSize).forEach{ x in
			guard x > pathBoundingBox.minX && x < pathBoundingBox.maxX else {return}
			
			let p1 = CGPoint(x: x, y: pathBoundingBox.minY)
			let p2 = CGPoint(x: x, y: pathBoundingBox.maxY)
			linesBuilding.addLines(between: [p1, p2])
		}
		stride(from: yStart + gridSize, to: rect.maxY, by: gridSize).forEach{ y in
			guard y > pathBoundingBox.minY && y < pathBoundingBox.maxY else {return}
			
			let p1 = CGPoint(x: pathBoundingBox.minX, y: y)
			let p2 = CGPoint(x: pathBoundingBox.maxX, y: y)
			linesBuilding.addLines(between:[p1, p2])
		}
		lines = linesBuilding
		
		area = cells.reduce(CGFloat(0), { $0 + ($1?.area() ?? 0) })
		
		assert(nCols%2 == 1)
		assert(nRows%2 == 1)
		assert(cells.count == nCols*nRows)
		assert(CGFloat(nCols)*gridSize - rect.width  < gridSize*2)
		assert(CGFloat(nRows)*gridSize - rect.height < gridSize*2)
//		print("Computation time: \(-computationStartDate.timeIntervalSinceNow)")
		
		/* *** TESTING THE doSegmentsIntersect METHOD *** */
//		/* true */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1)),
//			Segment(p0: CGPoint(x: 0, y: 1), p1: CGPoint(x: 1, y: 0))
//		))
//		/* true */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1)),
//			Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1))
//		))
//		/* false */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0,   y: 0),   p1: CGPoint(x: 1, y: 1)),
//			Segment(p0: CGPoint(x: 0.6, y: 0.4), p1: CGPoint(x: 1, y: 0))
//		))
//		/* true */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0,     y: 0),     p1: CGPoint(x: 1, y: 1)),
//			Segment(p0: CGPoint(x: 0.499, y: 0.501), p1: CGPoint(x: 1, y: 0))
//		))
//		/* true */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0,   y: 0),   p1: CGPoint(x: 1, y: 1)),
//			Segment(p0: CGPoint(x: 0.5, y: 0.5), p1: CGPoint(x: 1, y: 0))
//		))
//		/* true */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1)),
//			Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 0, y: 0))
//		))
//		/* false */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0,   y: 0),   p1: CGPoint(x: 0, y: 0)),
//			Segment(p0: CGPoint(x: 0.2, y: 0.1), p1: CGPoint(x: 1, y: 0))
//		))
//		/* false */
//		print(Grid.doSegmentsIntersect(
//			Segment(p0: CGPoint(x: 0,  y: 0), p1: CGPoint(x: 0, y: 1)),
//			Segment(p0: CGPoint(x: -1, y: 2), p1: CGPoint(x: 1, y: 2))
//		))
		
		/* *** TESTING THE projectedPoint METHOD *** */
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.projectedPoint(
//			CGPoint(x: 1, y: 0),
//			on: (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
//		))
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.projectedPoint(
//			CGPoint(x: 0, y: 1),
//			on: (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
//		))
//		/* (x: 1, y: 1) */
//		print(Grid.projectedPoint(
//			CGPoint(x: 1, y: 1),
//			on: (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
//		))
	}
	
	subscript(coordinate: Coordinate) -> Quadrilateral? {
		return self[coordinate.col, coordinate.row]
	}
	
	subscript(col: Int, row: Int) -> Quadrilateral? {
		assert(row >= 0 && row < nRows)
		assert(col >= 0 && col < nCols)
		return cells[col + row*nCols]
	}
	
	func coordinatesIntersectingSurfaceBetweenCircles(_ c0: Circle, _ c1: Circle, blacklisted: Set<Coordinate> = []) -> Set<Coordinate> {
		var result = Set<Coordinate>()
		
		let maxRadius = max(c0.radius, c1.radius)
		let minReachablePoint = CGPoint(x: min(c0.center.x, c1.center.x) - maxRadius, y: min(c0.center.y, c1.center.y) - maxRadius)
		let maxReachablePoint = CGPoint(x: max(c0.center.x, c1.center.x) + maxRadius, y: max(c0.center.y, c1.center.y) + maxRadius)
		
		for col in 0..<nCols {
			for row in 0..<nRows {
				let c = Grid.Coordinate(col: col, row: row)
				guard let q = self[c] else {continue}
				guard !blacklisted.contains(c) else {continue}
				
				let enclosingRect = square(at: c)
				/* Basic detection of unreachable quadrilaterals. */
				guard enclosingRect.minX <= maxReachablePoint.x else {continue}
				guard enclosingRect.minY <= maxReachablePoint.y else {continue}
				guard enclosingRect.maxX >= minReachablePoint.x else {continue}
				guard enclosingRect.maxY >= minReachablePoint.y else {continue}
				
				if q.points.contains(where: { $0.distance(from: c0.center) <= c0.radius || $0.distance(from: c1.center) <= c1.radius }) {
					/* The quadrilateral has at least one point inside at least one
					 * of the circles (easiest case). */
					result.insert(c)
					continue
				}
				
				/* Basic detection did not see a hit. Let’s dig deeper. */
				
				let segmentBetweenC0AndC1Centers = Segment(p0: c0.center, p1: c1.center)
				if let perpendicularNormalizedVector = segmentBetweenC0AndC1Centers.normalizedCounterClockwisePerpendicularVector() {
					/* Do any of the segments of the quadrilateral intersect with the
					 * segment from the center of c1 to the center of c2? Note we’re
					 * in the “perpendicular vector” if because there is no need to
					 * check this if we can’t get the perpendicular vector (segment
					 * is empty). */
					if q.segments.contains(where: { Grid.doSegmentsIntersect($0, segmentBetweenC0AndC1Centers) }) {
						result.insert(c)
						continue
					}
					
					/* Now let’s check the same thing, but for multiple segments all
					 * between the two circles.
					 * Note: There are a few structure that could be computed outside
					 *       the loop to optimize a bit. We assume things will go
					 *       fast and leave it as-is for the moment. */
					let interval = gridSize/2
					let nSteps = Int((maxRadius / interval).rounded(.awayFromZero))
					let c0StepDistance = c0.radius/CGFloat(nSteps)
					let c1StepDistance = c1.radius/CGFloat(nSteps)
					for step in 1...nSteps {
						let c0Distance = c0StepDistance * CGFloat(step)
						let c1Distance = c1StepDistance * CGFloat(step)
						let segment1 = Segment(
							p0: c0.center.pointMoving(along: perpendicularNormalizedVector, distance: c0Distance),
							p1: c1.center.pointMoving(along: perpendicularNormalizedVector, distance: c1Distance)
						)
						let segment2 = Segment(
							p0: c0.center.pointMoving(along: perpendicularNormalizedVector, distance: -c0Distance),
							p1: c1.center.pointMoving(along: perpendicularNormalizedVector, distance: -c1Distance)
						)
						if q.segments.contains(where: { Grid.doSegmentsIntersect($0, segment1) || Grid.doSegmentsIntersect($0, segment2) }) {
							result.insert(c)
							continue
						}
					}
				}
				
				/* TODO? Dig even deeper:
				 *    -> Do any of the segments of the quadrilateral intersect with
				 *       either of the circles. */
			}
		}
		
		return result
	}
	
	func square(at coordinates: Coordinate) -> CGRect {
		assert(coordinates.row >= 0 && coordinates.row < nRows)
		assert(coordinates.col >= 0 && coordinates.col < nCols)
		return CGRect(
			x: xStart + CGFloat(coordinates.col) * gridSize,
			y: yStart + CGFloat(coordinates.row) * gridSize,
			width: gridSize, height: gridSize
		)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private let xStart, yStart: CGFloat
	private let cells: [Quadrilateral?]
	
	/** Returns true if both segments intersect.
	
	From https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
	Other links of interest:
	  - https://martin-thoma.com/how-to-check-if-two-line-segments-intersect/
	  - https://stackoverflow.com/a/3838357 */
	private static func doSegmentsIntersect(_ s0: Segment, _ s1: Segment) -> Bool {
		/* Given three colinear points p, q, r, the function checks if point q
		 * lies on line segment 'pr' */
		func isPointOnSegment(_ s: Segment, _ p: CGPoint) -> Bool {
			/* We assume the three points are colinear */
			return (
				p.x <= max(s.p0.x, s.p1.x) && p.x >= min(s.p0.x, s.p1.x) &&
				p.y <= max(s.p0.y, s.p1.y) && p.y >= min(s.p0.y, s.p1.y)
			)
		}
		
		enum Orientation : Equatable {
			
			case colinear
			case clockwise
			case counterclockwise
			
			init(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint) {
				/* See https://www.geeksforgeeks.org/orientation-3-ordered-points/
				 * for details of below formula. */
				let v = (
					(p1.y - p0.y) * (p2.x - p1.x) -
					(p1.x - p0.x) * (p2.y - p1.y)
				)
				
				guard abs(v) > 0.000001 else {
					self = .colinear
					return
				}
				
				self = (v > 0 ? .clockwise : .counterclockwise)
			}
		}
		
		/* Find the four orientations needed for general and special cases. */
		let o0 = Orientation(s0.p0, s0.p1, s1.p0)
		let o1 = Orientation(s0.p0, s0.p1, s1.p1)
		let o2 = Orientation(s1.p0, s1.p1, s0.p0)
		let o3 = Orientation(s1.p0, s1.p1, s0.p1)
		
		/* General case */
		if o0 != o1 && o2 != o3 {return true}
		
		/* *** Special Cases *** */
		
		/* s0.p0, s0.p1 and s1.p0 are colinear and s1.p0 lies on segment s0 */
		if o0 == .colinear && isPointOnSegment(s0, s1.p0) {return true}
		
		/* s0.p0, s0.p1 and s1.p1 are colinear and s1.p1 lies on segment s0 */
		if o1 == .colinear && isPointOnSegment(s0, s1.p1) {return true}
		
		/* s1.p0, s1.p1 and s0.p0 are colinear and s0.p0 lies on segment s1 */
		if o2 == .colinear && isPointOnSegment(s1, s0.p0) {return true}
		
		/* s1.p0, s1.p1 and s0.p1 are colinear and s0.p1 lies on segment s1 */
		if o3 == .colinear && isPointOnSegment(s1, s0.p1) {return true}
		
		return false
	}
	
	private static func projectedPoint(_ p: CGPoint, on line: (CGPoint, CGPoint)) -> CGPoint? {
		let dx = line.1.x - line.0.x
		let dy = line.1.y - line.0.y
		
		let denomin = dx * dx + dy * dy
		guard denomin > 0.000001 else {
			/* The points of the line are too close, or even equal. */
			return nil
		}
		
		let coeffForIntersectPoint = (
			((line.1.x - line.0.x) * (p.x - line.0.x) +
			 (line.1.y - line.0.y) * (p.y - line.0.y)) /
			denomin
		)
		return CGPoint(x: line.0.x + coeffForIntersectPoint*(line.1.x - line.0.x),
							y: line.0.y + coeffForIntersectPoint*(line.1.y - line.0.y))
	}
	
	/* We assume points are correct (p not in path and d in path).
	 * Note this method uses a terrible algorithm. We should use maths to find
	 * the value we want instead of iterating points on the lines until I we
	 * reach what we search for…
	 * See https://martin-thoma.com/how-to-check-if-two-line-segments-intersect/ */
	private static func nearestPoint(in path: CGPath, from p: CGPoint, direction d: CGPoint) -> CGPoint {
		let precision = CGFloat(0.001)
		
		var curP = p
		var t = CGFloat(1)
		let xm = p.x-d.x, ym = p.y-d.y
		while !path.contains(curP) {
			curP.x = t*xm + d.x
			curP.y = t*ym + d.y
			t -= precision
			
			guard t >= 0 else {
				/* We did the whole line between p and d, but still did not find a
				 * point in the line contained in the path. Either the input values
				 * are incorrect, or we were not precise enough.
				 * In order to return something, we’ll return the point in the
				 * middle between p and d. */
				return CGPoint(x: (p.x + d.x)/2, y: (p.y + d.y)/2)
			}
		}
		return curP
	}
	
}
